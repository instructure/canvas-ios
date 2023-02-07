//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import Core
import AVKit

protocol SubmissionDetailsViewProtocol: ColoredNavViewProtocol, SubmissionButtonViewProtocol {
    func reload()
    func reloadNavBar()
    func embed(_ controller: UIViewController?)
    func embedInDrawer(_ controller: UIViewController?)
    var navigationItem: UINavigationItem { get }
}

class SubmissionDetailsPresenter {
    let context: Context
    let assignmentID: String
    let userID: String
    let env: AppEnvironment
    weak var view: SubmissionDetailsViewProtocol?
    let submissionButtonPresenter: SubmissionButtonPresenter
    var submissionButtonText: String? {
        guard let course = course.first, let assignment = assignment.first else { return nil }
        return submissionButtonPresenter.buttonText(course: course, assignment: assignment, quiz: quizzes?.first, onlineUpload: nil)
    }
    var pageViewEventName: String {
        return "/\(context.pathComponent)/assignments/\(assignmentID)/submissions/\(userID)"
    }

    lazy var submissions = env.subscribe(GetSubmission(context: context, assignmentID: assignmentID, userID: userID)) { [weak self] in
        self?.update()
    }

    /** The purpose of this property is to filter out placeholder `Submission` objects returned by the API in case there are no submissions yet. After the first submission, these entities are still in the database but we don't want to show them in the submission picker. */
    var pickerSubmissions: [Submission] { submissions.all.filter { $0.submittedAt != nil } }

    lazy var assignment = env.subscribe(GetAssignment(courseID: context.id, assignmentID: assignmentID)) { [weak self] in
        self?.update()
    }

    lazy var course = env.subscribe(GetCourse(courseID: context.id)) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var arc = env.subscribe(GetArc(courseID: context.id)) { [weak self] in
        self?.updateArc()
    }

    var quizzes: Store<GetQuiz>?

    var selectedAttempt: Int?
    var selectedFileID: String?
    var selectedDrawerTab = Drawer.Tab.comments
    var currentAssignment: Assignment?
    var currentFileID: String?
    var currentSubmission: Submission?
    var currentDrawerTab: Drawer.Tab?
    // Used for student_annotation type submissions to launch DocViewer
    private var docViewerSessionURL: URL?
    private var docViewerSessionRequest: APITask?

    init(env: AppEnvironment = .shared, view: SubmissionDetailsViewProtocol, context: Context, assignmentID: String, userID: String) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.env = env
        self.view = view
        self.submissionButtonPresenter = SubmissionButtonPresenter(view: view, assignmentID: assignmentID)
    }

    func viewIsReady() {
        submissions.refresh(force: true)
        assignment.refresh(force: true)
        course.refresh()
        arc.refresh()
        view?.reloadNavBar()
    }

    func update() {
        guard submissions.requested, !submissions.pending else {
            return
        }

        if quizzes?.useCase.quizID != assignment.first?.quizID {
            quizzes = assignment.first?.quizID.flatMap { quizID in env.subscribe(GetQuiz(courseID: context.id, quizID: quizID)) { [weak self] in
                self?.update()
            } }
            quizzes?.refresh()
        }

        let assignment = self.assignment.first
        let submission = submissions.filter({ $0.attempt == selectedAttempt }).first ?? submissions.first
        selectedAttempt = submission?.attempt ?? selectedAttempt
        if submission?.attachments?.contains(where: { $0.id == selectedFileID }) != true {
            selectedFileID = submission?.attachments?.sorted(by: File.idCompare).first?.id
        }

        let assignmentChanged = assignment != currentAssignment
        let fileIDChanged = currentFileID != selectedFileID
        let submissionChanged = submission != currentSubmission
        let submissionWasNil = currentSubmission == nil && submissionChanged
        let drawerTabChanged = selectedDrawerTab != currentDrawerTab
        currentAssignment = assignment
        currentFileID = selectedFileID
        currentSubmission = submission
        currentDrawerTab = selectedDrawerTab

        if drawerTabChanged || submissionWasNil || (submissionChanged && selectedDrawerTab == .files) {
            view?.embedInDrawer(viewControllerForDrawer())
        }
        if assignmentChanged || fileIDChanged || submissionChanged {
            if let submission = submission, case submission.type = SubmissionType.student_annotation {
                requestDocviewerSession(for: submission.id, attempt: submission.attempt)
            } else {
                view?.embed(viewControllerForContent())
            }
        }
        view?.reload()
        view?.reloadNavBar()
    }

    func updateArc() {
        if let arcID = arc.first?.id {
            submissionButtonPresenter.arcID = .some(arcID)
        } else {
            submissionButtonPresenter.arcID = .none
        }
        update()
    }

    private func requestDocviewerSession(for submissionId: String, attempt: Int) {
        docViewerSessionRequest?.cancel()
        docViewerSessionRequest = env.api.makeRequest(CanvaDocsSessionRequest(submissionId: submissionId, attempt: "\(attempt)")) { [weak self] response, _, _ in
            self?.docViewerSessionRequest = nil
            guard let docViewerSessionURL = response?.canvadocs_session_url else { return }
            self?.docViewerSessionURL = docViewerSessionURL.rawValue
            performUIUpdate {
                self?.view?.embed(self?.viewControllerForContent())
            }
        }
    }

    @objc func quizRefresh(_ notification: Notification) {
        guard notification.userInfo?["quizID"] as? String == assignment.first?.quizID else { return }
        assignment.refresh(force: true)
        submissions.refresh(force: true)
        quizzes?.refresh(force: true)
    }

    func select(attempt: Int, fileID: String? = nil) {
        selectedAttempt = attempt
        selectedFileID = fileID
        update()
    }

    func select(fileID: String) {
        selectedFileID = fileID
        update()
    }

    func select(drawerTab: Drawer.Tab?) {
        selectedDrawerTab = drawerTab ?? .comments
        update()
    }

    func viewControllerForContent() -> UIViewController? {
        guard let submission = currentSubmission, let assignment = currentAssignment, lockedEmptyViewIsHidden() else {
            return nil
        }

        // external tools submission may be unsubmitted and the type nil but there could
        // still be a submission inside the tool
        if assignment.requiresLTILaunch(toViewSubmission: submission) {
            let tools = LTITools(
                env: .shared,
                context: context,
                launchType: .assessment,
                assignmentID: assignmentID
            )
            return LTIViewController.create(tools: tools)
        }

        switch submission.type {
        case .some(.online_quiz):
            if let quizID = assignment.quizID,
                let url = URL(string: "/courses/\(assignment.courseID)/quizzes/\(quizID)/history?version=\(selectedAttempt ?? 1)&headless=1", relativeTo: env.api.baseURL) {
                let controller = CoreWebViewController(invertColorsInDarkMode: true)
                controller.webView.accessibilityIdentifier = "SubmissionDetails.onlineQuizWebView"
                controller.webView.load(URLRequest(url: url))
                return controller
            }
        case .some(.online_text_entry):
            let controller = CoreWebViewController()
            controller.webView.accessibilityIdentifier = "SubmissionDetails.onlineTextEntryWebView"
            controller.webView.loadHTMLString(submission.body ?? "")
            return controller
        case .some(.online_upload):
            if let attachment = submission.attachments?.first(where: { $0.id == selectedFileID }),
                let url = attachment.url {
                if attachment.mimeClass == "audio" || attachment.mimeClass == "video" {
                    let player = AVPlayer(url: url)
                    let controller = AVPlayerViewController()
                    controller.player = player
                    controller.view.accessibilityIdentifier = "SubmissionDetails.mediaPlayer"
                    return controller
                } else if attachment.contentType == "image/heic" {
                    let imageView = UIImageView()
                    imageView.contentMode = .scaleAspectFit
                    imageView.load(url: url)
                    let controller = UIViewController()
                    controller.view = imageView
                    return controller
                } else if let previewURL = attachment.previewURL {
                    return DocViewerViewController.create(
                        filename: attachment.filename,
                        previewURL: previewURL,
                        fallbackURL: url,
                        navigationItem: view?.navigationItem
                    )
                }
                let controller = CoreWebViewController(invertColorsInDarkMode: true)
                controller.webView.accessibilityIdentifier = "SubmissionDetails.webView"
                controller.webView.load(URLRequest(url: url))
                return controller
            }
        case .some(.discussion_topic):
            guard let previewUrl = submission.previewUrl else { break }

            let controller = CoreWebViewController(invertColorsInDarkMode: true)
            controller.webView.accessibilityIdentifier = "SubmissionDetails.discussionWebView"
            controller.webView.load(URLRequest(url: previewUrl))
            return controller
        case .some(.online_url):
            return UrlSubmissionContentViewController.create(submission: submission)
        case .some(.media_recording):
            guard let mediaUrl = submission.mediaComment?.url else {
                return nil
            }
            let player = AVPlayer(url: mediaUrl)
            let controller = AVPlayerViewController()
            controller.player = player
            controller.view.accessibilityIdentifier = "SubmissionDetails.mediaPlayer"
            return controller
        case .some(.basic_lti_launch):
            let tools = LTITools(
                env: .shared,
                context: context,
                url: submission.externalToolURL
            )
            return LTIViewController.create(tools: tools)
        case .student_annotation:
            guard let docViewerSessionURL = docViewerSessionURL else { return nil }
            return DocViewerViewController.create(
                filename: "", // filename unknown because this isn't a file the user attached but one attached to the assignment
                previewURL: docViewerSessionURL,
                fallbackURL: docViewerSessionURL,
                navigationItem: view?.navigationItem
            )
        default:
            return nil
        }
        return nil
    }

    func viewControllerForDrawer() -> UIViewController? {
        guard let submission = currentSubmission else { return nil }
        switch (selectedDrawerTab) {
        case .comments:
            return SubmissionCommentsViewController.create(
                env: env,
                context: context,
                assignmentID: assignmentID,
                userID: userID,
                submissionID: submission.id,
                submissionPresenter: self
            )
        case .files:
            return SubmissionFilesViewController.create(
                files: submission.attachments?.sorted(by: File.idCompare),
                presenter: self
            )
        case .rubric:
            return RubricViewController.create(
                env: env,
                courseID: context.id,
                assignmentID: assignmentID,
                userID: userID
            )
        }
    }

    func submit(button: UIView) {
        guard let assignment = assignment.first else { return }
        submissionButtonPresenter.submitAssignment(assignment, button: button)
    }

    func lockedEmptyViewIsHidden() -> Bool {
        if let assignment = assignment.first {
            let isHidden = ( assignment.lockExplanation == nil && !(assignment.lockedForUser) )
                || (assignment.submission != nil && assignment.submission?.workflowState != .unsubmitted)
            return isHidden
        }
        return true
    }

    func lockedEmptyViewHeader() -> String {
        return assignment.first?.quizID != nil ? NSLocalizedString("Quiz Locked", comment: "") : NSLocalizedString("Assignment Locked", comment: "")
    }
}
