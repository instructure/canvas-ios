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
    func update(assignment: Assignment, baseURL: URL?)
    func showSubmitAssignmentButton(title: String?)
    func chooseSubmissionType(_ types: [SubmissionType])
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

class AssignmentDetailsPresenter {
    enum FileSubmissionState {
        case pending, failed
    }

    enum FilePickerTag: Int {
        case onlineUpload, mediaRecording
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

    var fileUploadInProgress = false
    lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: Scope.where(#keyPath(File.assignmentID), equals: assignmentID)) { [weak self] in
        self?.update()
        let files = self?.files.map { $0 } ?? []
        self?.filePicker?.files = files
        self?.filePicker?.reload()

        if self?.fileUploadInProgress == true && files.allSatisfy({ $0.isUploaded }) {
            self?.fileUploadInProgress = false
            self?.view?.dismiss(animated: true, completion: nil)
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
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.fragment = fragment
    }

    func update() {
        guard let assignment = assignments.first, let course = courses.first else { return }
        let baseURL = fragmentHash.flatMap { URL(string: $0, relativeTo: assignment.htmlURL) } ?? assignment.htmlURL
        if let submission = assignment.submission {
            userID = submission.userID
        }
        showSubmitAssignmentButton(assignment: assignment, course: course)
        view?.updateNavBar(subtitle: course.name, backgroundColor: course.color)
        view?.update(assignment: assignment, baseURL: baseURL)
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

    func showSubmitAssignmentButton(assignment: Assignment?, course: Course?) {
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

        if canSubmit {
            let title = assignment.submission?.workflowState == .unsubmitted
                ? NSLocalizedString("Submit Assignment", comment: "")
                : NSLocalizedString("Resubmit Assignment", comment: "")

            view?.showSubmitAssignmentButton(title: title)
        } else {
            view?.showSubmitAssignmentButton(title: nil)
        }
    }

    func viewFileSubmission(from viewController: UIViewController) {
        showOnlineUpload()
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
            showOnlineUpload()
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
            showMediaRecording()
        default:
            break
        }
    }

    private func showOnlineUpload() {
        let filePicker = FilePickerViewController.create()
        filePicker.title = NSLocalizedString("Submission", bundle: .student, comment: "")
        filePicker.cancelButtonTitle = NSLocalizedString("Cancel Submission", bundle: .student, comment: "")
        filePicker.delegate = self
        let allowedUTIs = assignment?.allowedUTIs ?? []
        if allowedUTIs.contains(where: { $0.isAny || $0.isImage || $0.isVideo }) {
            filePicker.sources = [.camera, .library, .files]
        } else {
            filePicker.sources = [.files]
        }
        filePicker.files = self.files.map { $0 }
        filePicker.utis = allowedUTIs
        self.filePicker = filePicker
        let nav = UINavigationController(rootViewController: filePicker)
        view?.present(nav, animated: true) {
            filePicker.view.tag = FilePickerTag.onlineUpload.rawValue
        }
    }

    private func cancelOnlineUpload() {
        filePicker?.dismiss(animated: true) {
            let context = self.env.database.viewContext
            context.performAndWait {
                for file in self.files {
                    self.fileUploader.cancel(file)
                    context.delete(file)
                }
                do {
                    try context.save()
                } catch {
                    self.view?.showError(error)
                }
            }
        }
    }

    private func submitOnlineUpload() {
        filePicker?.dismiss(animated: true) {
            for file in self.files {
                self.fileUploader.upload(file, context: .submission(courseID: self.courseID, assignmentID: self.assignmentID)) { [weak self] error in
                    if let error = error {
                        self?.view?.showError(error)
                    }
                }
            }
        }
    }

    private func showMediaRecording() {
        let filePicker = FilePickerViewController.create()
        filePicker.title = NSLocalizedString("Submission", bundle: .student, comment: "")
        filePicker.cancelButtonTitle = NSLocalizedString("Cancel Submission", bundle: .student, comment: "")
        filePicker.delegate = self
        filePicker.sources = [.audio, .video]
        self.filePicker = filePicker
        let nav = UINavigationController(rootViewController: filePicker)
        view?.present(nav, animated: true) {
            filePicker.view.tag = FilePickerTag.mediaRecording.rawValue
        }
    }

    private func cancelMediaRecording() {
        filePicker?.dismiss(animated: true) {
            // TODO: cancel media task
            let context = self.env.database.viewContext
            context.performAndWait {
                for file in self.files {
                    context.delete(file)
                }
                do {
                    try context.save()
                } catch {
                    self.view?.showError(error)
                }
            }
        }
    }

    private func submitMediaRecording() {
        guard
            let file = files.first,
            let url = file.localFileURL,
            let type = MediaCommentType(extension: url.pathExtension),
            let userID = userID
        else {
            return
        }
        UploadMedia(type: type, url: url, file: file).fetch(environment: env) { [weak self] mediaID, error in
            guard let self = self else { return }
            if let error = error {
                self.updateFile(file, error: error)
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
            createSubmission.fetch(environment: self.env) { [weak self] _, _, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.updateFile(file, error: error)
                        return
                    }
                    self?.updateFile(file, delete: true)
                    self?.filePicker?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    private func updateFile(_ file: File, error: Error? = nil, delete: Bool = false) {
        let context = env.database.viewContext
        context.perform {
            file.uploadError = error?.localizedDescription
            if delete {
                context.delete(file)
            }
            try? context.save()
        }
    }
}

extension AssignmentDetailsPresenter: FilePickerControllerDelegate {
    func cancel(_ controller: FilePickerViewController) {
        switch FilePickerTag(rawValue: controller.view.tag) {
        case .onlineUpload?:
            cancelOnlineUpload()
        case .mediaRecording?:
            cancelMediaRecording()
        case nil: break
        }
    }

    func submit(_ controller: FilePickerViewController) {
        switch FilePickerTag(rawValue: controller.view.tag) {
        case .onlineUpload?:
            submitOnlineUpload()
        case .mediaRecording?:
            submitMediaRecording()
        case nil: break
        }
    }

    func retry(_ controller: FilePickerViewController) {
        // TODO: retry
    }

    func add(_ controller: FilePickerViewController, url: URL) {
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

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return files.count > 0
    }
}
