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
    case staged, uploading, failed, completed, reSubmissionFailed
}

protocol AssignmentDetailsViewProtocol: SubmissionButtonViewProtocol {
    var accessibilityFocusAfterAttemptSelection: UIView? { get }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?)
    func update(assignment: Assignment, quiz: Quiz?, submission: Submission?, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
    func updateAttemptPickerButton(isActive: Bool,
                                   attemptDate: String,
                                   items: [UIAction])
    func updateGradeCell(_ assignment: Assignment, submission: Submission?)
    func updateAttemptInfo(attemptNumber: String)
}

class AssignmentDetailsPresenter {

    var pageViewEventName: String {
        return "/courses/\(courseID)/assignments/\(assignmentID)"
    }

    lazy var arc = env.subscribe(GetArc(courseID: courseID)) { [weak self] in
        self?.updateArc()
    }

    private let includes: [GetAssignmentRequest.GetAssignmentInclude] = [.submission, .score_statistics]

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: includes)) { [weak self] in
        self?.update()
    }
    lazy var submissions = env.subscribe(GetSubmission(context: .course(courseID), assignmentID: assignmentID, userID: userID)) { [weak self] in
        self?.updateSubmissionPickerButton()
        self?.selectLatestSubmissionIfNecessary()
        self?.update()
    }
    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }
    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.update()
    }
    lazy var features = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID))) { [weak self] in
        self?.updateSubmissionPickerButton()
        self?.update()
    }

    var quizzes: Store<GetQuiz>?

    let env: AppEnvironment
    weak var view: AssignmentDetailsViewProtocol?
    let courseID: String
    let assignmentID: String
    var userID: String = ""
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
    var lockExplanation: String {
        guard let assignment = assignment else { return "" }

        switch assignment.lockStatus {
        case .before:
            guard let unlockAt = assignment.unlockAt else { return "" }
            return String.localizedStringWithFormat(String(localized: "This assignment is locked until %@", bundle: .student), unlockAt.dateTimeString)
        case .after:
            guard let lockAt = assignment.lockAt else { return "" }
            return String.localizedStringWithFormat(String(localized: "This assignment was locked %@", bundle: .student), lockAt.dateTimeString)
        default:
            return assignment.lockExplanation ?? ""
        }
    }
    private var fileCleanupPending = true
    private var submissionFinishedNotification: NSObjectProtocol?
    private var validSubmissions: [Submission] {
        submissions.all.filter { $0.submittedAt != nil }
    }
    private var selectedSubmission: Submission? {
        didSet {
            if let selectedSubmission {
                updateAttemptInfo(submission: selectedSubmission)
            }

            if let assignment {
                view?.updateGradeCell(assignment, submission: selectedSubmission)
            }
        }
    }

    init(env: AppEnvironment, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, fragment: String? = nil) {
        self.env = env
        self.view = view
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
        self.submissionButtonPresenter = SubmissionButtonPresenter(env: env, view: view, assignmentID: assignmentID)
        if let session = env.currentSession {
            self.userID = session.userID.localID
        }
        subscribeToSuccessfulSubmissionNotification(assignmentID: assignmentID)
    }

    private func subscribeToSuccessfulSubmissionNotification(assignmentID: String) {
        submissionFinishedNotification = NotificationCenter.default.addObserver(forName: UploadManager.AssignmentSubmittedNotification,
                                                                                object: nil,
                                                                                queue: OperationQueue.main) { [weak self] notification in
            if notification.userInfo?["assignmentID"] as? String == assignmentID {
                self?.onlineUploadState = .completed
            }
        }
    }

    func update() {
        if submissions.requested == false || submissions.pending {
            return
        }
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
        if assignments.requested && !assignments.pending && fileCleanupPending {
            fileCleanupPending = false
            UploadManager.shared.cleanupDanglingFiles(assignment: assignment)
        }
        let title = submissionButtonPresenter.buttonText(course: course, assignment: assignment, quiz: quizzes?.first, onlineUpload: onlineUploadState)
        view?.showSubmitAssignmentButton(title: title)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, quiz: quizzes?.first, submission: selectedSubmission ?? assignment.submission, baseURL: baseURL)
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
            if let assignment = assignment, assignment.submissionStatus == .submitted {
                onlineUploadState = .reSubmissionFailed
            } else {
                onlineUploadState = .failed
            }
        } else if onlineUpload.allSatisfy({ $0.isUploaded }) {
            // A file uploaded to the file server doesn't mean it's also submitted to the assignment so we check both
            if let submission = assignment?.submission, submission.status == .submitted {
                // This state is not always reached because the file is deleted after a successful upload.
                // We listen to the successful upload notification to work around this.
                onlineUploadState = .completed
            } else {
                onlineUploadState = .uploading
            }
        } else if onlineUpload.first(where: { $0.isUploading }) != nil {
            onlineUploadState = .uploading
        } else {
            onlineUploadState = .staged
        }
    }

    private func updateSubmissionPickerButton() {
        let isActive = validSubmissions.count > 1 && features.isFeatureFlagEnabled(.assignmentEnhancements)
        let items: [UIAction] = {
            guard isActive else { return [] }
            return validSubmissions.map { submission in
                let date = submission.submittedAt?.dateTimeString ?? ""
                let attemptNumber = String.localizedAttemptNumber(submission.attempt)
                return UIAction(title: date, subtitle: attemptNumber) { [weak self] _ in
                    self?.selectedSubmission = submission
                    let a11yFocusTarget = self?.view?.accessibilityFocusAfterAttemptSelection
                    UIAccessibility.post(notification: .screenChanged, argument: a11yFocusTarget)
                }
            }
        }()
        let attemptDate = validSubmissions.first?.submittedAt?.dateTimeString ?? ""
        view?.updateAttemptPickerButton(isActive: isActive,
                                        attemptDate: attemptDate,
                                        items: items)
    }

    private func updateAttemptInfo(submission: Submission) {
        let attemptNumber = String.localizedAttemptNumber(submission.attempt)
        view?.updateAttemptInfo(attemptNumber: attemptNumber)
    }

    private func selectLatestSubmissionIfNecessary() {
        if let selectedSubmission {
            if let latestSubmission = validSubmissions.first, latestSubmission.attempt > selectedSubmission.attempt {
                // A new attempt arrived possibly from a new submission, switch to that
                self.selectedSubmission = latestSubmission
            }
        } else {
            selectedSubmission = validSubmissions.first
        }
    }

    func viewIsReady() {
        colors.refresh()
        courses.refresh(force: true)
        assignments.refresh(force: true)
        arc.refresh()
        onlineUpload.refresh()
        features.refresh()
        submissions.refresh()

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
        features.refresh(force: true)
        submissions.refresh(force: true)

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
        env.database.performWriteTask { context in
            Submission.save(submission, in: context)
            try? context.save()
        }
        refresh()
    }

    func routeToSubmission(view: UIViewController) {
        var route = "/courses/\(courseID)/assignments/\(assignmentID)/submissions/\(userID)"

        if let selectedSubmission {
            route += "?selectedAttempt=\(selectedSubmission.attempt)"
        }

        env.router.route(to: route, from: view)
    }

    func route(to url: URL, from view: UIViewController) -> Bool {
        var dest = url
        if url.path.contains("/files/") {
            dest = url.appendingQueryItems(
                URLQueryItem(name: "courseID", value: courseID),
                URLQueryItem(name: "assignmentID", value: assignmentID),
                URLQueryItem(name: "skipModuleItemSequence", value: "true")
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
        if let quiz = quizzes?.first, quiz.lockedForUser == false, assignment?.quizID == quiz.id, assignment?.hasAttemptsLeft == true {
            return false
        }

        return assignment?.lockStatus != .unlocked ||
            assignment?.lockedForUser == true ||
            assignment?.isSubmittable == false ||
            assignment?.submission?.excused == true ||
            assignment?.isMasteryPathAssignment == true ||
            (assignment?.canSubmit == false && (assignment?.isLTIAssignment != true))
    }

    func attemptsIsHidden() -> Bool {
        return (
            features.first(where: { $0.name == "assignment_attempts" })?.enabled != true ||
            assignment?.allowedAttempts == 0 ||
            assignment?.allowedAttempts == -1 ||
            assignment?.attemptPossible == false ||
            assignment?.lockStatus == .before ||
            assignment?.submissionTypes.contains(.online_quiz) == true // attempts show up elsewhere
        )
    }

    func statisticsIsHidden() -> Bool {
        // If there are no statistics, or the statistics are invalid, don't show them
        // (Valid statistics should have min <= mean <= max
        guard let scoreStatistics = assignment?.scoreStatistics else { return true }
        return (scoreStatistics.min > scoreStatistics.mean) || (scoreStatistics.mean > scoreStatistics.max)
    }

    func assignmentDescription() -> String {
        if let desc = assignments.first?.descriptionHTML, !desc.isEmpty { return desc }
        return String(localized: "No Content", bundle: .student)
    }
}
