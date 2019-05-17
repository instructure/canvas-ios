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
import SafariServices
import CoreData

struct SubmissionAction: Equatable {
    let title: String
    let route: Route
    let options: Router.RouteOptions
}

protocol AssignmentDetailsViewProtocol: ErrorViewController {
    func updateNavBar(subtitle: String?, backgroundColor: UIColor?)
    func update(assignment: Assignment, quiz: Quiz?, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
    func chooseSubmissionType(_ types: [SubmissionType])
    func chooseMediaRecordingType()
    func present(filePicker: FilePickerViewController)
}

class AssignmentDetailsPresenter {
    enum FileSubmissionState {
        case pending, failed
    }

    lazy var assignments = env.subscribe(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: [.submission])) { [weak self] in
        self?.update()
    }

    lazy var colors = env.subscribe(GetCustomColors()) { [weak self] in
        self?.update()
    }

    lazy var courses = env.subscribe(GetCourseUseCase(courseID: courseID)) { [weak self] in
        self?.update()
    }

    var quizzes: Store<GetQuiz>?

    var fileUploadInProgress = false
    lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: Scope.where(#keyPath(File.assignmentID), equals: assignmentID)) { [weak self] in
        self?.update()
        let files = self?.files.map { $0 } ?? []
        self?.filePicker?.files = files
        self?.filePicker?.reload()

        if self?.fileUploadInProgress == true && files.allSatisfy({ $0.isUploaded }) {
            self?.fileUploadInProgress = false
            self?.filePicker?.dismiss(animated: true, completion: nil)
        }
        self?.fileUploadInProgress = files.first { $0.isUploading } != nil
    }

    let env: AppEnvironment
    weak var view: AssignmentDetailsViewProtocol?
    weak var filePicker: FilePickerViewController?
    let courseID: String
    let assignmentID: String
    var userID: String?
    let fragment: String?
    var fragmentHash: String? {
        guard let fragment = fragment, !fragment.isEmpty else { return nil }
        return "#\(fragment)"
    }
    var fileUploader: FileUploader = UploadFile.shared
    var mediaUploader: UploadMedia?

    let supportedSubmissionTypes: [SubmissionType] = [
        .discussion_topic,
        .external_tool,
        .online_text_entry,
        .online_upload,
        .online_url,
        .media_recording,
    ]

    var assignment: Assignment? {
        return assignments.first
    }

    var fileSubmissionState: FileSubmissionState? {
        if files.isEmpty {
            return nil
        }
        let failed = files.first { $0.uploadError != nil } != nil
        return failed ? .failed : .pending
    }

    init(env: AppEnvironment = .shared, view: AssignmentDetailsViewProtocol, courseID: String, assignmentID: String, fragment: String? = nil) {
        self.env = env
        self.view = view
        self.courseID = ID.expandTildeID(courseID)
        self.assignmentID = ID.expandTildeID(assignmentID)
        self.fragment = fragment
    }

    func update() {
        if quizzes?.useCase.quizID != assignment?.quizID {
            quizzes = assignment?.quizID.flatMap { quizID in env.subscribe(GetQuiz(courseID: courseID, quizID: quizID)) { [weak self] in
                self?.update()
            } }
            quizzes?.refresh()
        }
        guard let assignment = assignments.first, let course = courses.first else { return }
        let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
        if let submission = assignment.submission {
            userID = submission.userID
        }
        let quiz = quizzes?.first
        showSubmitAssignmentButton(assignment: assignment, quiz: quiz, course: course)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, quiz: quiz, baseURL: baseURL)
    }

    func viewIsReady() {
        colors.refresh()
        courses.refresh()
        assignments.refresh()
        files.refresh()
    }

    func refresh() {
        courses.refresh(force: true)
        assignments.refresh(force: true)
        quizzes?.refresh(force: true)
    }

    func routeToSubmission(view: UIViewController) {
        guard let userID = userID else {
            return
        }
        env.router.route(to: .submission(forCourse: courseID, assignment: assignmentID, user: userID), from: view, options: nil)
    }

    func route(to url: URL, from view: UIViewController) -> Bool {
        var dest = url
        if url.path.contains("/files/") {
            dest = url.appendingQueryItems(
                URLQueryItem(name: "courseID", value: courseID),
                URLQueryItem(name: "assignmentID", value: assignmentID)
            )
        }
        env.router.route(to: dest, from: view, options: nil)
        return true
    }

    func showSubmitAssignmentButton(assignment: Assignment?, quiz: Quiz?, course: Course?) {
        guard let assignment = assignment, let course = course else { return }
        let canMakeSubmission = assignment.canMakeSubmissions
        let isOpen = assignment.isOpenForSubmissions()
        let amStudent = course.enrollments?.hasRole(.student) ?? false
        let filesUploading = !files.isEmpty
        let canSubmit = canMakeSubmission
            && isOpen
            && amStudent
            && !filesUploading

        if assignment.isDiscussion {
            view?.showSubmitAssignmentButton(title: NSLocalizedString("View Discussion", comment: ""))
            return
        }

        if assignment.isLTIAssignment {
            view?.showSubmitAssignmentButton(title: NSLocalizedString("Launch External Tool", comment: ""))
            return
        }

        if quiz != nil {
            // TODO: takeability
            view?.showSubmitAssignmentButton(title: NSLocalizedString("Take Quiz", comment: ""))
            return
        }

        if canSubmit {
            let title = assignment.submission?.workflowState == .unsubmitted
                ? NSLocalizedString("Submit Assignment", comment: "")
                : NSLocalizedString("Resubmit Assignment", comment: "")

            view?.showSubmitAssignmentButton(title: title)
        } else {
            view?.showSubmitAssignmentButton(title: nil)
        }
    }

    func submitAssignment(from viewController: UIViewController) {
        guard let assignment = assignments.first, assignment.canMakeSubmissions else {
            return
        }
        let supported = assignment.submissionTypes.filter { supportedSubmissionTypes.contains($0) }
        if supported.count == 1, let type = supported.first {
            submit(type, from: viewController)
            return
        }
        view?.chooseSubmissionType(supported)
    }

    func submit(_ type: SubmissionType, from viewController: UIViewController, completionBlock: (() -> Void)? = nil) {
        switch type {
        case .discussion_topic:
            guard let url = assignment?.discussionTopic?.htmlUrl else { return }
            env.router.route(to: url, from: viewController)
        case .online_text_entry:
            let route = Route.assignmentTextSubmission(courseID: courseID, assignmentID: assignmentID, userID: userID ?? "")
            env.router.route(to: route, from: viewController, options: [.modal, .embedInNav])
        case .online_upload:
            let filePicker = FilePickerViewController.create()
            filePicker.title = NSLocalizedString("Submission", bundle: .student, comment: "")
            filePicker.cancelButtonTitle = NSLocalizedString("Cancel Submission", bundle: .student, comment: "")
            let allowedUTIs = assignment?.allowedUTIs ?? []
            filePicker.sources = [.files]
            if assignment?.allowedExtensions.isEmpty == true || allowedUTIs.contains(where: { $0.isImage || $0.isVideo }) {
                filePicker.sources.append(contentsOf: [.library, .camera])
            }
            filePicker.files = self.files.map { $0 }
            filePicker.utis = allowedUTIs
            self.filePicker = filePicker
            view?.present(filePicker: filePicker)
        case .online_url:
            let route = Route.assignmentUrlSubmission(courseID: courseID, assignmentID: assignmentID, userID: userID ?? "")
            env.router.route(to: route, from: viewController, options: [.modal, .embedInNav])
        case .external_tool:
            guard let assignment = assignment else {
                return
            }
            let context = ContextModel(.course, id: assignment.courseID)
            let lti = LTITools(env: env, context: context, id: nil, url: nil, launchType: .assessment, assignmentID: assignment.id, moduleItemID: nil)
            lti.getSessionlessLaunchURL { [weak self] url in
                guard let url = url else {
                    return
                }
                let vc = SFSafariViewController(url: url)
                self?.env.router.route(to: vc, from: viewController, options: [.modal])
                completionBlock?()
            }
        case .media_recording:
            view?.chooseMediaRecordingType()
        default:
            break
        }
    }

    func addOnlineUpload(file url: URL) {
        let context = env.database.viewContext
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.localFileURL = url
                file.size = url.lookupFileSize()
                file.prepareForSubmission(courseID: self.courseID, assignmentID: self.assignmentID)
                try context.save()
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func cancelOnlineUpload() {
        let context = self.env.database.viewContext
        context.performAndWait {
            for file in self.files {
                self.fileUploader.cancel(file)
                context.delete(file)
            }
            try? context.save()
        }
    }

    func submitOnlineUpload() {
        for file in files {
            self.fileUploader.upload(file, context: .submission(courseID: courseID, assignmentID: assignmentID)) { [weak self] error in
                if let error = error {
                    self?.view?.showError(error)
                }
            }
        }
    }

    func submit(mediaRecording url: URL, type: MediaCommentType, callback: @escaping (Error?) -> Void) {
        guard let userID = userID else { return }
        mediaUploader = UploadMedia(type: type, url: url)
        mediaUploader?.fetch(environment: env) { [weak self] mediaID, error in
            guard let self = self else { return }
            if let error = error {
                callback(error)
                return
            }
            let context = ContextModel(.course, id: self.courseID)
            let createSubmission = CreateSubmission(
                context: context,
                assignmentID: self.assignmentID,
                userID: userID,
                submissionType: .media_recording,
                mediaCommentID: mediaID,
                mediaCommentType: type
            )
            createSubmission.fetch(environment: self.env) { _, _, error in
                callback(error)
            }
        }
    }

    func cancelMediaRecording() {
        mediaUploader?.cancel()
    }
}
