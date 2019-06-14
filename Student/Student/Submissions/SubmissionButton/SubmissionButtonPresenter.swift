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

enum ArcID: Equatable {
    case pending
    case none
    case some(String)
}

class SubmissionButtonPresenter: NSObject {
    var assignment: Assignment?
    let assignmentID: String
    let env: AppEnvironment
    let fileUpload: UploadBatch
    var arcID: ArcID = .pending
    weak var view: SubmissionButtonViewProtocol?

    init(env: AppEnvironment = .shared, view: SubmissionButtonViewProtocol, assignmentID: String) {
        self.env = env
        self.view = view
        self.assignmentID = assignmentID
        self.fileUpload = UploadBatch(environment: env, batchID: "assignment-\(assignmentID)", callback: nil)
    }

    func buttonText(course: Course, assignment: Assignment, quiz: Quiz?) -> String? {
        if assignment.isDiscussion {
            return NSLocalizedString("View Discussion", bundle: .student, comment: "")
        }

        if assignment.isLTIAssignment {
            return NSLocalizedString("Launch External Tool", bundle: .student, comment: "")
        }

        if arcID == .pending {
            return nil
        }

        let canSubmit = (
            assignment.canMakeSubmissions &&
            assignment.isOpenForSubmissions() &&
            (course.enrollments?.hasRole(.student) ?? false) &&
            fileUpload.state == nil
        )
        guard canSubmit else { return nil }

        if quiz?.submission?.canResume == true {
            return NSLocalizedString("Resume Quiz", bundle: .student, comment: "")
        }
        if quiz?.submission?.attemptsLeft == 0 { return nil }
        if assignment.quizID != nil {
            return assignment.submission?.workflowState == .unsubmitted
                ? NSLocalizedString("Take Quiz", bundle: .student, comment: "")
                : NSLocalizedString("Retake Quiz", bundle: .student, comment: "")
        }

        return assignment.submission?.workflowState == .unsubmitted
            ? NSLocalizedString("Submit Assignment", bundle: .student, comment: "")
            : NSLocalizedString("Resubmit Assignment", bundle: .student, comment: "")
    }

    func submitAssignment(_ assignment: Assignment, button: UIView) {
        guard assignment.canMakeSubmissions else { return }
        self.assignment = assignment
        let types = assignment.submissionTypes
        let arc = types.contains(.online_upload) && arcID != .pending && arcID != .none
        if !arc && types.count == 1, let type = types.first {
            return submitType(type, for: assignment, button: button)
        }
        let alert = SubmissionButtonAlertView.chooseTypeAlert(self, assignment: assignment, arc: arc, button: button)
        view?.present(alert, animated: true, completion: nil)
    }

    func submitType(_ type: SubmissionType, for assignment: Assignment, button: UIView) {
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
            pickMediaRecordingType(button: button)
        case .online_text_entry:
            let route = Route.assignmentTextSubmission(courseID: courseID, assignmentID: assignment.id, userID: userID)
            env.router.route(to: route, from: view, options: [.modal, .embedInNav])
        case .online_quiz:
            guard let quizID = assignment.quizID else { return }
            env.router.route(to: .takeQuiz(forCourse: courseID, quizID: quizID), from: view, options: [.modal, .embedInNav])
        case .online_upload:
            pickFiles(for: assignment)
        case .online_url:
            let route = Route.assignmentUrlSubmission(courseID: courseID, assignmentID: assignment.id, userID: userID)
            env.router.route(to: route, from: view, options: [.modal, .embedInNav])
        case .none, .not_graded, .on_paper:
            break
        }
    }

    // MARK: - arc
    func submitArc(assignment: Assignment) {
        guard case let .some(arcID) = arcID, let userID = assignment.submission?.userID else { return }
        let arc = ArcSubmissionViewController.create(environment: env, courseID: assignment.courseID, assignmentID: assignment.id, userID: userID, arcID: arcID)
        let nav = UINavigationController(rootViewController: arc)
        view?.present(nav, animated: true, completion: nil)
    }

    // MARK: - online_upload
    lazy var filePicker = FilePickerViewController.create(environment: env, batchID: "assignment-\(assignmentID)")
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
    }

    func submit(_ controller: FilePickerViewController) {
        guard let assignment = assignment else { return }
        controller.dismiss(animated: true) {
            let context = self.env.database.viewContext
            context.performAndWait {
                do {
                    let files: [File] = context.all(where: #keyPath(File.batchID), equals: self.fileUpload.batchID)
                    for file in files {
                        file.prepareForSubmission(courseID: assignment.courseID, assignmentID: assignment.id)
                    }
                    try context.save()
                    self.fileUpload.upload(to: .submission(courseID: assignment.courseID, assignmentID: assignment.id))
                } catch {
                    self.view?.showError(error)
                }
            }
        }
    }

    func cancel(_ controller: FilePickerViewController) {
        controller.dismiss(animated: true) {
            self.fileUpload.cancel()
        }
    }

    func retry(_ controller: FilePickerViewController) {
        // TODO: presenter?.retryOnlineUpload()
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return controller.files?.isEmpty == false
    }
}

// MARK: - media_recording
extension SubmissionButtonPresenter: AudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func pickMediaRecordingType(button: UIView) {
        let alert = SubmissionButtonAlertView.chooseMediaTypeAlert(self, button: button)
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
            let success = UIAlertController(title: NSLocalizedString("Successfully submitted!", bundle: .student, comment: ""), message: nil, preferredStyle: .alert)
            self?.view?.present(success, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    success.dismiss(animated: true, completion: nil)
                }
            }
        }
        let doneUploading = { (error: Error?) -> Void in
            DispatchQueue.main.async { uploading.dismiss(animated: true) {
                if let error = error { return reportError(error) }
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
