//
// Copyright (C) 2019-present Instructure, Inc.
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
import SafariServices
import UIKit
import Core

protocol SubmissionButtonViewProtocol: ApplicationViewController, ErrorViewController {
}

class SubmissionButtonPresenter: NSObject {
    var assignment: Assignment?
    let assignmentID: String
    let env: AppEnvironment
    weak var view: SubmissionButtonViewProtocol?

    init(env: AppEnvironment = .shared, view: SubmissionButtonViewProtocol, assignmentID: String) {
        self.env = env
        self.view = view
        self.assignmentID = assignmentID
    }

    func buttonText(course: Course, assignment: Assignment, quiz: Quiz?) -> String? {
        if assignment.isDiscussion {
            return NSLocalizedString("View Discussion", bundle: .student, comment: "")
        }

        if assignment.isLTIAssignment {
            return NSLocalizedString("Launch External Tool", bundle: .student, comment: "")
        }

        if quiz != nil {
            // TODO: takeability
            return NSLocalizedString("Take Quiz", bundle: .student, comment: "")
        }

        let canSubmit = (
            assignment.canMakeSubmissions &&
            assignment.isOpenForSubmissions() &&
            (course.enrollments?.hasRole(.student) ?? false) &&
            files.isEmpty
        )
        guard canSubmit else { return nil }

        return assignment.submission?.workflowState == .unsubmitted
            ? NSLocalizedString("Submit Assignment", bundle: .student, comment: "")
            : NSLocalizedString("Resubmit Assignment", bundle: .student, comment: "")
    }

    func submitAssignment(_ assignment: Assignment, button: UIView) {
        guard assignment.canMakeSubmissions else { return }
        self.assignment = assignment
        let types = assignment.submissionTypes
        if types.count == 1, let type = types.first {
            return submitType(type, for: assignment)
        }

        let alert = SubmissionButtonAlertView.chooseTypeAlert(self, assignment: assignment, button: button)
        view?.present(alert, animated: true, completion: nil)
    }

    func submitType(_ type: SubmissionType, for assignment: Assignment) {
        guard let view = view as? UIViewController, let userID = assignment.submission?.userID else { return }
        let courseID = assignment.courseID
        switch type {
        case .basic_lti_launch, .external_tool:
            LTITools(
                env: env,
                context: ContextModel(.course, id: courseID),
                launchType: .assessment,
                assignmentID: assignment.id
            ).getSessionlessLaunchURL { [weak self] url in
                guard let url = url else { return }
                let safari = SFSafariViewController(url: url)
                self?.env.router.route(to: safari, from: view, options: .modal)
            }
        case .discussion_topic:
            guard let url = assignment.discussionTopic?.htmlUrl else { return }
            env.router.route(to: url, from: view)
        case .media_recording:
            pickMediaRecordingType()
        case .online_text_entry:
            let route = Route.assignmentTextSubmission(courseID: courseID, assignmentID: assignment.id, userID: userID)
            env.router.route(to: route, from: view, options: [.modal, .embedInNav])
        case .online_quiz:
            break // TODO
        case .online_upload:
            pickFiles(for: assignment)
        case .online_url:
            let route = Route.assignmentUrlSubmission(courseID: courseID, assignmentID: assignment.id, userID: userID)
            env.router.route(to: route, from: view, options: [.modal, .embedInNav])
        case .none, .not_graded, .on_paper:
            break
        }
    }

    // MARK: - online_upload
    lazy var filePicker = FilePickerViewController.create()
    var fileUploader: FileUploader = UploadFile.shared
    var fileUploadInProgress = false
    lazy var files: Store<LocalUseCase<File>> = env.subscribe(scope: Scope.where(#keyPath(File.assignmentID), equals: assignmentID)) { [weak self] in
        let files = self?.files.map { $0 } ?? []
        self?.filePicker.files = files
        self?.filePicker.reload()

        if self?.fileUploadInProgress == true && files.allSatisfy({ $0.isUploaded }) {
            self?.fileUploadInProgress = false
            self?.filePicker.dismiss(animated: true, completion: nil)
        }
        self?.fileUploadInProgress = files.first { $0.isUploading } != nil
    }
}

extension SubmissionButtonPresenter: FilePickerControllerDelegate {
    func pickFiles(for assignment: Assignment) {
        self.assignment = assignment
        filePicker.title = NSLocalizedString("Submission", bundle: .student, comment: "")
        filePicker.cancelButtonTitle = NSLocalizedString("Cancel Submission", bundle: .student, comment: "")
        let allowedUTIs = assignment.allowedUTIs
        filePicker.sources = [.files]
        if assignment.allowedExtensions.isEmpty == true || allowedUTIs.contains(where: { $0.isImage || $0.isVideo }) {
            filePicker.sources.append(contentsOf: [.library, .camera])
        }
        filePicker.utis = allowedUTIs
        filePicker.delegate = self
        view?.present(UINavigationController(rootViewController: filePicker), animated: true, completion: nil)
        files.refresh()
    }

    func add(_ controller: FilePickerViewController, url: URL) {
        guard let assignment = assignment else { return }
        let context = env.database.viewContext
        context.performAndWait {
            do {
                let file: File = context.insert()
                file.localFileURL = url
                file.size = url.lookupFileSize()
                file.prepareForSubmission(courseID: assignment.courseID, assignmentID: assignment.id)
                try context.save()
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func submit(_ controller: FilePickerViewController) {
        guard let assignment = assignment else { return }
        controller.dismiss(animated: true) {
            for file in self.files {
                self.fileUploader.upload(file, context: .submission(courseID: assignment.courseID, assignmentID: assignment.id)) { [weak self] error in
                    if let error = error {
                        self?.view?.showError(error)
                    }
                }
            }
        }
    }

    func cancel(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true) {
            let context = self.env.database.viewContext
            context.performAndWait {
                for file in self.files {
                    self.fileUploader.cancel(file)
                    context.delete(file)
                }
                try? context.save()
            }
        }
    }

    func retry(_ controller: FilePickerViewController) {
        // TODO: presenter?.retryOnlineUpload()
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return files.isEmpty == false
    }
}

// MARK: - media_recording
extension SubmissionButtonPresenter: AudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickMediaRecordingType() {
        let alert = SubmissionButtonAlertView.chooseMediaTypeAlert(self)
        view?.present(alert, animated: true, completion: nil)
    }

    func cancel(_ controller: AudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func send(_ controller: AudioRecorderViewController, url: URL) {
        controller.dismiss(animated: true) {
            self.submitMediaType(.audio, url: url)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) {
            do {
                if let videoURL = info[.mediaURL] as? URL {
                    let destination = URL
                        .temporaryDirectory
                        .appendingPathComponent("videos", isDirectory: true)
                        .appendingPathComponent(String(Clock.now.timeIntervalSince1970))
                        .appendingPathExtension(videoURL.pathExtension)
                    try videoURL.move(to: destination)
                    self.submitMediaType(.video, url: destination)
                }
            } catch {
                self.view?.showError(error)
            }
        }
    }

    func submitMediaType(_ type: MediaCommentType, url: URL, callback: @escaping (Error?) -> Void = { _ in }) {
        guard let assignment = assignment, let userID = assignment.submission?.userID else { return }
        let env = self.env
        let mediaUploader = UploadMedia(type: type, url: url)
        let uploading = SubmissionButtonAlertView.uploadingAlert(mediaUploader)
        let reportError = { [weak self] (error: Error) -> Void in
            let failure = UIAlertController(title: NSLocalizedString("Submission Failed", bundle: .student, comment: ""), message: error.localizedDescription, preferredStyle: .alert)
            failure.addAction(UIAlertAction(title: NSLocalizedString("Retry", bundle: .student, comment: ""), style: .default) { _ in
                self?.submitMediaType(type, url: url, callback: callback)
            })
            failure.addAction(UIAlertAction(title: NSLocalizedString("Cancel", bundle: .student, comment: ""), style: .cancel))
            self?.view?.present(failure, animated: true, completion: nil)
        }
        let reportSuccess = { [weak self] in
            let success = UIAlertController(title: NSLocalizedString("Success!", bundle: .student, comment: ""), message: nil, preferredStyle: .alert)
            self?.view?.present(success, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
                    success.dismiss(animated: true, completion: nil)
                }
            }
        }
        let doneUploading = { (error: Error?) -> Void in
            DispatchQueue.main.async { uploading.dismiss(animated: true) {
                if let error = error { reportError(error) }
                reportSuccess()
            } }
        }
        let createSubmission = { (mediaID: String?, error: Error?) -> Void in
            guard error == nil else { return doneUploading(error) }
            CreateSubmission(
                context: ContextModel(.course, id: assignment.courseID),
                assignmentID: assignment.id,
                userID: userID,
                submissionType: .media_recording,
                mediaCommentID: mediaID,
                mediaCommentType: type
            ).fetch(environment: env) { _, _, error in doneUploading(error) }
        }
        let upload = { mediaUploader.fetch(environment: env, createSubmission) }
        view?.present(uploading, animated: true, completion: upload)
    }
}
