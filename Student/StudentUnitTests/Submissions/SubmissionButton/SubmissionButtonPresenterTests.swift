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

import XCTest
@testable import Student
@testable import Core
import SafariServices
import TestsFoundation

class SubmissionButtonPresenterTests: StudentTestCase {
    class View: UIViewController, SubmissionButtonViewProtocol {
        var presented: UIViewController?
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            presented = viewControllerToPresent
            completion?()
        }

        var resultingError: NSError?
        func showError(_ error: Error) {
            resultingError = error as NSError
        }

        var didChooseMediaRecordingType = false
        func chooseMediaRecordingType() {
            didChooseMediaRecordingType = true
        }
    }

    class MockFilePicker: FilePickerViewController {
        var dismissed = false
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissed = true
            completion?()
        }
    }

    class MockAudioRecorder: AudioRecorderViewController {
        var dismissed = false
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissed = true
            completion?()
        }
    }

    class MockImagePicker: UIImagePickerController {
        var dismissed = false
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissed = true
            completion?()
        }
    }

    let audioRecorder = MockAudioRecorder()
    let button = UIView()
    let imagePicker = MockImagePicker()
    var presenter: SubmissionButtonPresenter!
    let filePicker = MockFilePicker()
    var view: View!

    override func setUp() {
        super.setUp()
        router.resetExpectations()
        view = View()
        presenter = SubmissionButtonPresenter(env: env, view: view, assignmentID: "1")
        presenter.assignment = Assignment.make(from: .make(submission: .make()))
        presenter.arcID = .none
    }

    func xtestButtonText() {
        let a = Assignment.make(from: .make(
            submission: .make(workflow_state: .unsubmitted),
            submission_types: [ .online_upload ]
        ))
        let c = Course.make(from: .make(enrollments: [ .make(type: "observer") ]))
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil))

        c.enrollments?.first?.type = "student"
        c.enrollments?.first?.role = "SomethingCustom"
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil), "Submit Assignment")

        a.submission?.workflowState = .submitted
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil), "Resubmit Assignment")

        a.submission?.workflowState = .graded
        a.submission?.submittedAt = nil
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil), "Submit Assignment")

        a.submissionTypes = [ .discussion_topic ]
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil), "View Discussion")

        a.submissionTypes = [ .external_tool ]
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil), "Launch External Tool")

        presenter.arcID = .pending
        a.submissionTypes = [.online_upload]
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil))

        presenter.arcID = .none
        a.submissionTypes = [ .online_quiz ]
        let quiz = Quiz.make()
        a.quizID = quiz.id
        quiz.submission = QuizSubmission.make(from: .make(started_at: Date()))
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: quiz, onlineUpload: nil), "Resume Quiz")
        quiz.submission = QuizSubmission.make(from: .make(attempts_left: 0))
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: quiz, onlineUpload: nil))
        quiz.submission = nil
        a.submission?.submittedAt = Date()
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: quiz, onlineUpload: nil), "Retake Quiz")
        a.submission?.submittedAt = nil
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: quiz, onlineUpload: nil), "Take Quiz")

        a.submissionTypes = [ .online_upload ]
        a.lockedForUser = true
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil))
    }

    func xtestSubmitAssignment() {
        let a = Assignment.make(from: .make(submission_types: [ .none ]))
        presenter.submitAssignment(a, button: button)
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)

        a.submissionTypes = [ .online_text_entry ]
        presenter.submitAssignment(a, button: button)
        XCTAssert(router.viewControllerCalls.last?.0 is TextSubmissionViewController)
    }

    func xtestSubmitAssignmentChoose() {
        let a = Assignment.make(from: .make(submission_types: [ .online_text_entry, .online_url ]))
        presenter.submitAssignment(a, button: button)
        XCTAssert(view.presented is UIAlertController)
        XCTAssert(router.calls.isEmpty)
    }

    func xtestSubmitAssignmentChooseArc() {
        let a = Assignment.make(from: .make(submission_types: [ .online_upload ]))
        presenter.arcID = .some("1")
        presenter.submitAssignment(a, button: button)
        let alert = view.presented as? UIAlertController
        drainMainQueue()
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.actions.count, 3)
    }

    func xtestSubmitTypeMissingSubmission() {
        let a = Assignment.make(from: .make(submission: nil))
        presenter.submitType(.online_text_entry, for: a, button: UIView())
        drainMainQueue()
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)
    }

    func xtestSubmitTypeLTI() {
        let a = Assignment.make(from: .make(
            discussion_topic: .make(html_url: URL(string: "/discussion"))
        ))
        presenter.submitType(.external_tool, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.viewControllerCalls.isEmpty)

        let request = GetSessionlessLaunchURLRequest(context: .course("1"), id: nil, url: nil, assignmentID: "1", moduleItemID: nil, launchType: .assessment)
        api.mock(request, value: .make(url: URL(string: "https://instructure.com")!))
        presenter.submitType(.external_tool, for: a, button: UIView())
        wait(for: [router.showExpectation], timeout: 5)
        XCTAssert(router.viewControllerCalls.first?.0 is SFSafariViewController)
    }

    func xtestSubmitTypeDiscussion() {
        let url = URL(string: "/discussion")!
        let a = Assignment.make(from: .make(discussion_topic: .make()))
        presenter.submitType(.discussion_topic, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.calls.isEmpty)

        a.discussionTopic?.htmlURL = url
        presenter.submitType(.discussion_topic, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.lastRoutedTo(URL(string: "/discussion")!))
    }

    func xtestSubmitTypeMedia() {
        let a = Assignment.make()
        presenter.submitType(.media_recording, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(view.presented is UIAlertController)
    }

    func xtestSubmitTypeText() {
        let a = Assignment.make()
        presenter.submitType(.online_text_entry, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.viewControllerCalls.last?.0 is TextSubmissionViewController)
    }

    func xtestSubmitTypeQuiz() {
        let a = Assignment.make()
        presenter.submitType(.online_quiz, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.calls.isEmpty)
        a.quizID = "1"
        presenter.submitType(.online_quiz, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.lastRoutedTo(Route.takeQuiz(forCourse: "1", quizID: "1")))
    }

    func xtestSubmitTypeUpload() {
        let a = Assignment.make()
        presenter.submitType(.online_upload, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(view.presented is UINavigationController)
    }

    func xtestSubmitTypeURL() {
        let a = Assignment.make()
        presenter.submitType(.online_url, for: a, button: UIView())
        drainMainQueue()
        XCTAssert(router.viewControllerCalls.last?.0 is UrlSubmissionViewController)
    }

    func xtestSubmitArc() {
        let a = Assignment.make()
        presenter.arcID = .some("4")
        presenter.submitArc(assignment: a)
        drainMainQueue()
        let nav = view.presented as? UINavigationController
        XCTAssertNotNil(nav)
        XCTAssertNotNil(nav?.topViewController as? ArcSubmissionViewController)
    }

    func xtestSubmitTypeBad() {
        let a = Assignment.make()
        presenter.submitType(.on_paper, for: a, button: UIView())
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)
    }

    func xtestPickFilesEmptyExtensions() {
        let a = Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: []))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [.online_upload])
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func xtestPickFilesFilesOnly() {
        let a = Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: [ "txt" ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [ .online_upload ])
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files])
    }

    func xtestPickFilesImages() {
        let a = Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: [ "jpg" ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [ .online_upload ])
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func xtestSubmitFiles() {
        presenter.submit(filePicker)
        XCTAssert(filePicker.dismissed)
    }

    func xtestRetryFileUpload() {
        XCTAssertNoThrow(presenter.retry(filePicker))
    }

    func xtestCancelFileUpload() {
        presenter.cancel(filePicker)
        XCTAssertTrue(uploadManager.cancelWasCalled)
    }

    func xtestCanSubmitFilePicker() throws {
        XCTAssertFalse(presenter.canSubmit(filePicker))
        let url = URL.temporaryDirectory.appendingPathComponent("SubmissionButtonPresenterTests-submit-files.txt")
        FileManager.default.createFile(atPath: url.path, contents: "test".data(using: .utf8), attributes: nil)
        try UploadManager.shared.add(url: url, batchID: presenter.batchID)
        let filePicker = FilePickerViewController.create(batchID: presenter.batchID)
        XCTAssertTrue(presenter.canSubmit(filePicker))
    }

    func xtestCancelAudioRecording() {
        presenter.cancel(audioRecorder)
        XCTAssert(audioRecorder.dismissed)
    }

    func xtestSendAudioRecording() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.send(audioRecorder, url: url)
        XCTAssertNotNil(view.presented)
    }

    func xtestImagePickerControllerVideo() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.imagePickerController(imagePicker, didFinishPickingMediaWithInfo: [.mediaURL: url])
        XCTAssert(imagePicker.dismissed)
    }
}
