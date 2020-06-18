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
import CoreData

struct SubmissionAction: Equatable {
    let title: String
    let route: String
    let options: RouteOptions
}

enum OnlineUploadState {
    case staged, uploading, failed, completed
}

protocol AssignmentDetailsViewProtocol: SubmissionButtonViewProtocol {
    func updateNavBar(subtitle: String?, backgroundColor: UIColor?)
    func update(assignment: Assignment, quiz: Quiz?, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
}

class AssignmentDetailsPresenter: PageViewLoggerPresenterProtocol {

    var pageViewEventName: String {
        return "/courses/\(courseID)/assignments/\(assignmentID)"
    }

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }

    lazy var arc = env.subscribe(GetArc(courseID: courseID)) { [weak self] in
        self?.updateArc()
    }

    var quizzes: Store<GetQuiz>?

    let env: AppEnvironment
    weak var view: AssignmentDetailsViewProtocol?
    let courseID: String
    let assignmentID: String
    var userID: String?
    let fragment: String?
    var fragmentHash: String? {
        guard let fragment = fragment, !fragment.isEmpty else { return nil }
        return "#\(fragment)"
    }
    var submissionButtonPresenter: SubmissionButtonPresenter

    var assignment: Assignment? {
        return assignments.first
    }

    lazy var onlineUpload = UploadManager.shared.subscribe(batchID: "assignment-\(assignmentID)") { [weak self] in
        self?.updateOnlineUpload()
    }
    var onlineUploadState: OnlineUploadState? {
        didSet {
            if onlineUploadState != oldValue {
                update()
            }
        }
    }

    init(env: AppEnvironment = .shared,
         view: AssignmentDetailsViewProtocol,
         courseID: String,
         assignmentID: String,
         fragment: String? = nil) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
        self.submissionButtonPresenter = SubmissionButtonPresenter(env: env, view: view, assignmentID: assignmentID)
        if let session = env.currentSession {
            self.userID = session.userID
        }
    }

    func update() {
        if quizzes?.useCase.quizID != assignment?.quizID {
            quizzes = assignment?.quizID.flatMap { quizID in env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
                self?.update()
            } }
            quizzes?.refresh()
        }
        guard let assignment = assignment, let course = courses.first else { return }
        guard quizzes?.pending != true else { return }
        let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
        if let submission = assignment.submission {
            userID = submission.userID
        }
        let title = submissionButtonPresenter.buttonText(course: course, assignment: assignment, quiz: quizzes?.first, onlineUpload: onlineUploadState)
        view?.showSubmitAssignmentButton(title: title)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, quiz: quizzes?.first, baseURL: baseURL)
    }

    func updateArc() {
        if let arcID = arc.first?.id {
            submissionButtonPresenter.arcID = .some(arcID)
        } else {
            submissionButtonPresenter.arcID = .none
        }
        update()
    }

    func updateOnlineUpload() {
        if onlineUpload.isEmpty {
            onlineUploadState = nil
        } else if onlineUpload.first(where: { $0.uploadError != nil }) != nil {
            onlineUploadState = .failed
        } else if onlineUpload.allSatisfy({ $0.isUploaded }) {
            onlineUploadState = .completed
        } else if onlineUpload.first(where: { $0.isUploading }) != nil {
            onlineUploadState = .uploading
        } else {
            onlineUploadState = .staged
        }
    }

    func viewIsReady() {
        colors.refresh()
        courses.refresh(force: true)
        assignments.refresh(force: true)
        arc.refresh()
        onlineUpload.refresh()

        NotificationCenter.default.addObserver(self, selector: #selector(quizRefresh(_:)), name: .quizRefresh, object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(uploadSubmitted(notification:)),
            name: UploadManager.AssignmentSubmittedNotification, object: nil
        )
        NotificationCenter.default.post(moduleItem: .assignment(assignmentID), completedRequirement: .view, courseID: courseID)
    }

    func refresh() {
        courses.refresh(force: true)
        assignments.refresh(force: true)
        quizzes?.refresh(force: true)

        submissionButtonPresenter.arcID = .pending
        arc.refresh(force: true)
    }

    @objc func quizRefresh(_ notification: Notification) {
        guard notification.userInfo?["quizID"] as? String == assignment?.quizID else { return }
        assignments.refresh(force: true)
        quizzes?.refresh(force: true)
    }

    @objc func uploadSubmitted(notification: Notification) {
        guard
            let assignmentID = notification.userInfo?["assignmentID"] as? String,
            let submission = notification.userInfo?["submission"] as? APISubmission,
            assignmentID == self.assignmentID
        else { return }
        env.database.performBackgroundTask { context in
            Submission.save(submission, in: context)
            try? context.save()
        }
    }

    func routeToSubmission(view: UIViewController) {
        guard let userID = userID else {
            return
        }
        env.router.route(to: "/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)", from: view)
    }

    func route(to url: URL, from view: UIViewController) -> Bool {
        var dest = url
        if url.path.contains("/files/") {
            dest = url.appendingQueryItems(
                URLQueryItem(name: "courseID", value: courseID),
                URLQueryItem(name: "assignmentID", value: assignmentID)
            )
        }
        env.router.route(to: dest, from: view)
        return true
    }

    func submit(button: UIView) {
        guard let assignment = assignment else { return }
        submissionButtonPresenter.submitAssignment(assignment, button: button)
    }

    func viewFileSubmission() {
        guard let assignment = assignment else { return }
        submissionButtonPresenter.pickFiles(for: assignment, selectedSubmissionTypes: [.online_upload])
    }

    // MARK: - viewIsHidden methods

    func dueSectionIsHidden() -> Bool {
        return assignment?.lockStatus == .before
    }

    func lockedSectionIsHidden() -> Bool {
        return assignment?.lockExplanation == nil && !(assignment?.lockedForUser ?? false)
    }

    func lockedIconContainerViewIsHidden() -> Bool {
        return assignment?.lockStatus != .before
    }

    func fileTypesSectionIsHidden() -> Bool {
        return assignment?.lockStatus == .before || !(assignment?.hasFileTypes ?? false)
    }

    func submissionTypesSectionIsHidden() -> Bool {
        return assignment?.lockStatus == .before
    }

    func gradesSectionIsHidden() -> Bool {
        if let submission = assignment?.submission {
            return submission.workflowState == .unsubmitted
        } else {
            return true
        }
    }

    func viewSubmissionButtonSectionIsHidden() -> Bool {
        return assignment?.lockStatus == .before || assignment?.isMasteryPathAssignment == true
    }

    func descriptionIsHidden() -> Bool {
        return assignment?.lockStatus == .before
    }

    func submitAssignmentButtonIsHidden() -> Bool {
        return assignment?.lockStatus != .unlocked ||
            assignment?.lockedForUser == true ||
            assignment?.isSubmittable == false ||
            assignment?.submission?.excused == true ||
            assignment?.isMasteryPathAssignment == true
    }

    func assignmentDescription() -> String {
        if let desc = assignments.first?.descriptionHTML, !desc.isEmpty { return desc }
        return NSLocalizedString("No Content", comment: "")
    }
}
