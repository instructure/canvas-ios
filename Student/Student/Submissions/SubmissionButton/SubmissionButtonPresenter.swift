//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import SafariServices
import UIKit
import Core
import WebKit
import Lottie

protocol SubmissionButtonViewProtocol: ErrorViewController {
}

enum ArcID: Equatable {
    case pending
    case none
    case some(String)
}

class SubmissionButtonPresenter: NSObject {
    var assignment: Assignment?
    var instanceHost: String?

    let assignmentID: String
    let env = AppEnvironment.shared
    lazy var batchID = "assignment-\(assignmentID)"
    lazy var files = UploadManager.shared.subscribe(batchID: batchID, eventHandler: {})
    var arcID: ArcID = .pending
    weak var view: SubmissionButtonViewProtocol?
    var selectedSubmissionTypes: [SubmissionType] = []
    lazy var flags = env.subscribe(GetEnabledFeatureFlags(context: .currentUser)) {}

    init(view: SubmissionButtonViewProtocol, assignmentID: String) {
        self.view = view
        self.assignmentID = assignmentID
        super.init()

        flags.refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCelebrate(_:)), name: .celebrateSubmission, object: nil)
    }

    func show(_ controller: UIViewController, completion: (() -> Void)? = nil) {
        guard let view = view as? UIViewController else { return }
        env.router.show(controller, from: view, options: .modal(), completion: completion)
    }

    func buttonText(course: Course, assignment: Assignment, quiz: Quiz?, onlineUpload: OnlineUploadState?) -> String? {
        if assignment.isDiscussion {
            return String(localized: "View Discussion", bundle: .student)
        }

        if assignment.isLTIAssignment {
            return String(localized: "Launch External Tool", bundle: .student)
        }

        if arcID == .pending {
            return nil
        }

        let isQuizUnlocked = (
            quiz?.id != nil &&
            quiz?.lockedForUser == false &&
            assignment.hasAttemptsLeft
        )

        let canSubmit = (
            assignment.canMakeSubmissions &&
            (assignment.isOpenForSubmissions() || isQuizUnlocked) &&
            assignment.hasAttemptsLeft &&
            course.hasStudentEnrollment &&
            onlineUpload == nil
        )
        guard canSubmit else { return nil }

        if quiz?.submission?.canResume == true {
            return String(localized: "Resume Quiz", bundle: .student)
        }
        if quiz?.submission?.attemptsLeft == 0 { return nil }
        if assignment.quizID != nil {
            return assignment.submission?.submittedAt == nil
                ? String(localized: "Take Quiz", bundle: .student)
                : String(localized: "Retake Quiz", bundle: .student)
        }

        return assignment.submission?.workflowState == .unsubmitted || assignment.submission?.submittedAt == nil
            ? String(localized: "Submit Assignment", bundle: .student)
            : String(localized: "Resubmit Assignment", bundle: .student)
    }

    func submitAssignment(_ assignment: Assignment, button: UIView) {
        guard assignment.canMakeSubmissions else { return }
        self.assignment = assignment
        let types = assignment.submissionTypes
        let arc = arcID != .pending && arcID != .none && assignment.submissionTypes.isStudioAccepted(allowedExtensions: assignment.allowedExtensions)
        if !arc && types.count == 1, let type = types.first {
            return submitType(type, for: assignment, button: button)
        }
        let alert = SubmissionButtonAlertView.chooseTypeAlert(self, assignment: assignment, arc: arc, button: button)
        show(alert)
    }

    private func agent(from assignment: Assignment) -> SubmissionAgent? {
        guard let userID = assignment.submission?.userID else { return nil }

        return SubmissionAgent(
            courseID: assignment.courseID,
            assignmentID: assignment.id,
            userID: userID,
            instanceHost: instanceHost
        )
    }

    func submitType(_ type: SubmissionType, for assignment: Assignment, button: UIView) {
        Analytics.shared.logEvent("assignment_submit_selected")
        guard let view = view as? UIViewController else { return }
        let courseID = assignment.courseID
        switch type {
        case .basic_lti_launch, .external_tool:
            Analytics.shared.logEvent("assignment_launchlti_selected")
            LTITools(
                env: env,
                context: .course(courseID),
                id: assignment.externalToolContentID,
                launchType: .assessment,
                assignmentID: assignment.id
            ).presentTool(from: view, animated: true)
        case .discussion_topic:
            Analytics.shared.logEvent("assignment_detail_discussionlaunch")
            guard let url = assignment.discussionTopic?.htmlURL else { return }
            env.router.route(to: url, from: view)
        case .media_recording:
            Analytics.shared.logEvent("submit_mediarecording_selected")
            pickFiles(for: assignment, selectedSubmissionTypes: [type])
        case .online_text_entry:
            Analytics.shared.logEvent("submit_textentry_selected")
            guard let agent = agent(from: assignment) else { return }
            env.router.show(TextSubmissionViewController.create(
                agent: agent
            ), from: view, options: .modal(isDismissable: false, embedInNav: true))
        case .online_quiz:
            Analytics.shared.logEvent("assignment_detail_quizlaunch")
            guard let quizID = assignment.quizID else { return }
            env.router.show(StudentQuizWebViewController.create(
                courseID: courseID,
                quizID: quizID
            ), from: view, options: .modal(.fullScreen, isDismissable: false, embedInNav: true))
        case .online_upload:
            Analytics.shared.logEvent("submit_fileupload_selected")
            pickFiles(for: assignment, selectedSubmissionTypes: [type])
        case .online_url:
            Analytics.shared.logEvent("submit_url_selected")
            guard let agent = agent(from: assignment) else { return }
            env.router.show(UrlSubmissionViewController.create(
                agent: agent
            ), from: view, options: .modal(.formSheet, embedInNav: true))
        case .student_annotation:
            presentStudentAnnotation(assignment: assignment, view: view)
        case .none, .not_graded, .on_paper, .wiki_page:
            break
        }
    }

    private func presentStudentAnnotation(assignment: Assignment, view: UIViewController) {
        let courseScope = Scope(predicate: NSPredicate(format: "%K == %@", #keyPath(Course.id), assignment.courseID), order: [])

        guard
            let submissionId = assignment.submission?.id,
            let agent = agent(from: assignment),
            let course: Course = env.database.viewContext.fetch(scope: courseScope).first
        else {
            return
        }

        env.api.makeRequest(CanvaDocsSessionRequest(submissionId: submissionId), refreshToken: false) { [weak self] response, _, _ in
            guard let self = self, let docViewerSessionURL = response?.canvadocs_session_url else {
                return
            }

            let viewModel = StudentAnnotationSubmissionViewModel(
                documentURL: docViewerSessionURL.rawValue,
                agent: agent,
                annotatableAttachmentID: assignment.annotatableAttachmentID,
                assignmentName: assignment.name,
                courseColor: course.color
            )
            let submissionView = StudentAnnotationSubmissionView(viewModel: viewModel)

            performUIUpdate {
                let hostingView = CoreHostingController(submissionView)
                self.env.router.show(hostingView, from: view, options: .modal(.fullScreen, isDismissable: false, embedInNav: true, addDoneButton: false))
            }
        }
    }

    // MARK: - arc
    func submitArc(assignment: Assignment) {
        Analytics.shared.logEvent("submit_arc_selected")
        guard case let .some(arcID) = arcID, let agent = agent(from: assignment) else { return }
        let arc = ArcSubmissionViewController.create(environment: env, agent: agent, arcID: arcID)
        let nav = UINavigationController(rootViewController: arc)
        nav.modalPresentationStyle = .fullScreen
        show(nav)
    }

    private var isMediaRecording: Bool {
        return selectedSubmissionTypes.contains(.media_recording)
    }
}

extension SubmissionButtonPresenter: FilePickerControllerDelegate {
    func pickFiles(for assignment: Assignment, selectedSubmissionTypes: [SubmissionType]) {
        self.assignment = assignment
        self.selectedSubmissionTypes = selectedSubmissionTypes
        let filePicker = FilePickerViewController.create(batchID: isMediaRecording ? UUID.string : batchID)
        filePicker.title = String(localized: "Submission", bundle: .student)
        filePicker.cancelButtonTitle = String(localized: "Cancel Submission", bundle: .student)
        let allowedUTIs = selectedSubmissionTypes.allowedUTIs( allowedExtensions: assignment.allowedExtensions )
        let mediaTypes = selectedSubmissionTypes.allowedMediaTypes
        filePicker.sources = [.files]
        if assignment.allowedExtensions.isEmpty == true || allowedUTIs.contains(where: { $0.isImage || $0.isVideo }) {
            filePicker.sources.append(contentsOf: [.library, .camera])
            if !isMediaRecording { filePicker.sources.append(.documentScan) }
        }
        if isMediaRecording { filePicker.sources.append(.audio) }
        filePicker.utis = allowedUTIs
        filePicker.mediaTypes = mediaTypes
        filePicker.delegate = self
        filePicker.maxFileCount = isMediaRecording ? 1 : Int.max
        let nav = UINavigationController(rootViewController: filePicker)
        nav.modalPresentationStyle = .formSheet
        show(nav)
    }

    func submit(_ controller: FilePickerViewController) {
        guard let assignment = assignment else { return }
        if isMediaRecording {
            submitMediaRecording(controller)
        } else {
            let context = FileUploadContext.submission(courseID: assignment.courseID, assignmentID: assignment.id, comment: nil)
            UploadManager.shared.upload(batch: self.batchID, to: context)
        }
    }

    func submitMediaRecording(_ controller: FilePickerViewController) {
        guard let file = controller.files.first, let url = file.localFileURL, let uti = UTI(extension: url.pathExtension) else { return }
        let mediaType: MediaCommentType = uti.isAudio ? .audio : .video
        let objectID = file.objectID
        env.router.dismiss(controller) { [weak self] in
            self?.submitMediaType(mediaType, url: url, callback: { error in
                guard let file = try? UploadManager.shared.viewContext.existingObject(with: objectID) as? File else { return }
                UploadManager.shared.complete(file: file, error: error)
            })
        }
    }

    func cancel(_ controller: FilePickerViewController) {
        env.router.dismiss(controller) {
            UploadManager.shared.cancel(batchID: self.batchID)
        }
    }

    func retry(_ controller: FilePickerViewController) {
        submit(controller)
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return controller.files.isEmpty == false
    }
}

// MARK: - media_recording
extension SubmissionButtonPresenter: AudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func cancel(_ controller: AudioRecorderViewController) {
        env.router.dismiss(controller)
    }

    func send(_ controller: AudioRecorderViewController, url: URL) {
        env.router.dismiss(controller) {
            self.submitMediaType(.audio, url: url)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        env.router.dismiss(picker) {
            do {
                if let videoURL = info[.mediaURL] as? URL {
                    let destination = URL
                        .Directories
                        .temporary
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
        guard let assignment = assignment, let agent = agent(from: assignment) else { return }
        let env = self.env
        let mediaUploader = UploadMedia(type: type, url: url)
        let uploading = SubmissionButtonAlertView.uploadingAlert(mediaUploader)
        let reportError = { [weak self] (error: Error) in
            let failure = UIAlertController(title: String(localized: "Submission Failed", bundle: .student), message: error.localizedDescription, preferredStyle: .alert)
            failure.addAction(UIAlertAction(title: String(localized: "Retry", bundle: .student), style: .default) { _ in
                self?.submitMediaType(type, url: url, callback: callback)
            })
            failure.addAction(UIAlertAction(title: String(localized: "Cancel", bundle: .student), style: .cancel))
            self?.show(failure)
        }
        let reportSuccess = { [weak self] in
            let success = UIAlertController(title: String(localized: "Successfully submitted!", bundle: .student), message: nil, preferredStyle: .alert)
            self?.show(success) {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    env.router.dismiss(success)
                }
            }
        }
        let doneUploading = { [weak self] (error: Error?) in
            performUIUpdate { self?.env.router.dismiss(uploading) {
                if let error = error { return reportError(error) }
                reportSuccess()
            } }
        }
        let createSubmission = { (mediaID: String?, error: Error?) in
            guard error == nil else { return doneUploading(error) }
            CreateSubmission(
                agent: agent,
                submissionType: .media_recording,
                mediaCommentID: mediaID,
                mediaCommentType: type
            ).fetch(environment: env) { _, _, error in doneUploading(error) }
        }
        let upload = { mediaUploader.fetch(createSubmission) }
        show(uploading, completion: upload)
    }
}

extension SubmissionButtonPresenter {
    @objc func handleCelebrate(_ notification: Notification) {
        if flags.first(where: { $0.name == "disable_celebrations" })?.enabled != true,
            notification.userInfo?["assignmentID"] as? String == assignmentID {
            performUIUpdate { self.showConfetti() }
        }
    }

    func showConfetti() {
        let viewController = (view as? UIViewController)
        let hostViewWindow = viewController?.view.window
        let modallyPresentedViewWindow = viewController?.presentedViewController?.view.window

        guard let view = hostViewWindow ?? modallyPresentedViewWindow else { return }
        let animation = LottieAnimationView(name: "confetti", bundle: .core)
        view.addSubview(animation)
        animation.pin(inside: view)
        animation.contentMode = .scaleAspectFill
        animation.play { _ in
            animation.removeFromSuperview()
        }
    }
}
