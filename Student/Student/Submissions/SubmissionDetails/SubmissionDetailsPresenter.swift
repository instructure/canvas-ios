//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Core
import AVKit

public protocol SubmissionDetailsViewProtocol: ErrorViewController, ColoredNavViewProtocol {
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

    lazy var submissions: Store<GetSubmission> = {
        let useCase = GetSubmission(context: context, assignmentID: assignmentID, userID: userID)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var assignment: Store<GetAssignment> = {
        let useCase = GetAssignment(courseID: context.id, assignmentID: assignmentID)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    lazy var course: Store<GetCourseUseCase> = {
        let useCase = GetCourseUseCase(courseID: context.id)
        return env.subscribe(useCase) { [weak self] in
            self?.update()
        }
    }()

    var selectedAttempt: Int = 0
    var selectedFileID: String?
    var selectedDrawerTab = Drawer.Tab.comments
    var currentAssignment: Assignment?
    var currentFileID: String?
    var currentSubmission: Submission?
    var currentDrawerTab: Drawer.Tab?

    init(env: AppEnvironment = .shared, view: SubmissionDetailsViewProtocol, context: Context, assignmentID: String, userID: String) {
        self.context = context
        self.assignmentID = assignmentID
        self.userID = userID
        self.env = env
        self.view = view
    }

    func viewIsReady() {
        submissions.refresh(force: true)
        assignment.refresh()
        course.refresh()
        view?.reloadNavBar()
    }

    func update() {
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
            view?.embed(viewControllerForContent())
        }
        view?.reload()
        view?.reloadNavBar()
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
        view?.embedInDrawer(viewControllerForDrawer())
    }

    func viewControllerForContent() -> UIViewController? {
        guard let submission = currentSubmission, let assignment = currentAssignment else {
            return nil
        }

        // external tools submission may be unsubmitted and the type nil but there could
        // still be a submission inside the tool
        if assignment.submissionTypes.contains(.external_tool) {
            return ExternalToolSubmissionContentViewController.create(env: self.env, assignment: assignment)
        }

        switch submission.type {
        case .some(.online_quiz):
            if let quizID = assignment.quizID,
                let url = URL(string: "/courses/\(assignment.courseID)/quizzes/\(quizID)/history?version=\(selectedAttempt)&headless=1", relativeTo: env.api.baseURL) {
                let controller = CoreWebViewController(env: env)
                controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineQuizWebView"
                controller.webView.load(URLRequest(url: url))
                return controller
            }
        case .some(.online_text_entry):
            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.onlineTextEntryWebView"
            controller.webView.loadHTMLString(submission.body ?? "")
            return controller
        case .some(.online_upload):
            if let attachment = submission.attachments?.first(where: { $0.id == selectedFileID }),
                let filename = attachment.filename,
                let url = attachment.url {
                return DocViewerViewController.create(
                    filename: filename,
                    previewURL: attachment.previewURL,
                    fallbackURL: url,
                    navigationItem: view?.navigationItem,
                    env: env
                )
            }
        case .some(.discussion_topic):
            guard let previewUrl = submission.previewUrl else { break }

            let controller = CoreWebViewController(env: env)
            controller.webView.accessibilityIdentifier = "SubmissionDetailsPage.discussionWebView"
            controller.webView.load(URLRequest(url: previewUrl))
            return controller
        case .some(.online_url):
            return UrlSubmissionContentViewController.create(submission: submission)
        case .some(.media_recording):
            guard let mediaComment = submission.mediaComment else {
                return nil
            }
            let player = AVPlayer(url: mediaComment.url)
            let controller = AVPlayerViewController()
            controller.player = player
            controller.view.accessibilityIdentifier = "SubmissionDetailsPage.mediaPlayer"
            return controller
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
            return RubricViewController.create(env: env,
                                               courseID: context.id,
                                               assignmentID: assignmentID,
                                               userID: userID)
        }
    }

    func submit(from viewController: UIViewController) {
        // TODO: share submit button logic currently in AssignmentDetails
    }
}
