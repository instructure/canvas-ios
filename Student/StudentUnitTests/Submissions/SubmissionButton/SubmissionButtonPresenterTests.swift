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
        var resultingError: NSError?
        func showError(_ error: Error) {
            resultingError = error as NSError
        }

        var didChooseMediaRecordingType = false
        func chooseMediaRecordingType() {
            didChooseMediaRecordingType = true
        }
    }

    lazy var audioRecorder = AudioRecorderViewController.create()
    lazy var button = UIView()
    lazy var imagePicker = UIImagePickerController()
    lazy var presenter = SubmissionButtonPresenter(view: view, assignmentID: "1")
    lazy var filePicker: FilePickerViewController = {
        let picker = FilePickerViewController.create(batchID: presenter.batchID)
        picker.loadViewIfNeeded()
        return picker
    }()
    lazy var view = View()

    override func setUp() {
        super.setUp()
        presenter.assignment = Assignment.make(from: .make(submission: .make()))
        presenter.arcID = .none
    }

    func testButtonText() {
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

        a.lockedForUser = false
        a.allowedAttempts = 1
        a.submission = Submission.make(from: .make(attempt: 2))
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: nil, onlineUpload: nil))
    }

    func testSubmitAssignment() {
        let a = Assignment.make(from: .make(submission_types: [ .none ]))
        presenter.submitAssignment(a, button: button)
        XCTAssertNil(router.presented)

        a.submissionTypes = [ .online_text_entry ]
        presenter.submitAssignment(a, button: button)
        XCTAssert(router.presented is TextSubmissionViewController)
    }

    func testSubmitAssignmentChoose() {
        let a = Assignment.make(from: .make(submission_types: [ .online_text_entry, .online_url ]))
        presenter.submitAssignment(a, button: button)
        XCTAssert(router.presented is UIAlertController)
    }

    func testSubmitAssignmentChooseArc() {
        let a = Assignment.make(from: .make(submission_types: [ .online_upload ]))
        presenter.arcID = .some("1")
        presenter.submitAssignment(a, button: button)
        let alert = router.presented as? UIAlertController
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.actions.count, 3)
    }

    func testSubmitTypeMissingSubmission() {
        let a = Assignment.make(from: .make(submission: nil))
        presenter.submitType(.online_text_entry, for: a, button: UIView())
        XCTAssertNil(router.presented)
    }

    func testSubmitTypeLTI() {
        let a = Assignment.make(from: .make(
            discussion_topic: .make(html_url: URL(string: "/discussion")),
            external_tool_tag_attributes: .make(content_id: "1")
        ))
        presenter.submitType(.external_tool, for: a, button: UIView())
        XCTAssertNil(router.presented)

        let request = GetSessionlessLaunchURLRequest(
            context: .course("1"),
            id: "1",
            url: nil,
            assignmentID: "1",
            moduleItemID: nil,
            launchType: .assessment,
            resourceLinkLookupUUID: nil
        )
        api.mock(request, value: .make(url: URL(string: "https://instructure.com")!))
        presenter.submitType(.external_tool, for: a, button: UIView())
        wait(for: [router.showExpectation], timeout: 5)
        XCTAssert(router.presented is SFSafariViewController)
    }

    func testSubmitTypeDiscussion() {
        let url = URL(string: "/discussion")!
        let a = Assignment.make(from: .make(discussion_topic: .make()))
        presenter.submitType(.discussion_topic, for: a, button: UIView())
        XCTAssert(router.calls.isEmpty)

        a.discussionTopic?.htmlURL = url
        presenter.submitType(.discussion_topic, for: a, button: UIView())
        XCTAssert(router.lastRoutedTo(URL(string: "/discussion")!))
    }

    func testSubmitTypeMedia() {
        let a = Assignment.make()
        presenter.submitType(.media_recording, for: a, button: UIView())
        let nav = router.presented as? UINavigationController
        XCTAssertNotNil(nav)
        XCTAssertNotNil(nav?.viewControllers.first as? FilePickerViewController)
    }

    func testSubmitTypeText() {
        let a = Assignment.make()
        presenter.submitType(.online_text_entry, for: a, button: UIView())
        XCTAssert(router.presented is TextSubmissionViewController)
    }

    func testSubmitTypeQuiz() {
        let a = Assignment.make()
        presenter.submitType(.online_quiz, for: a, button: UIView())
        XCTAssert(router.calls.isEmpty)
        a.quizID = "1"
        presenter.submitType(.online_quiz, for: a, button: UIView())
        XCTAssert(router.presented is QuizWebViewController)
    }

    func testSubmitTypeUpload() {
        let a = Assignment.make()
        presenter.submitType(.online_upload, for: a, button: UIView())
        let nav = router.presented as? UINavigationController
        XCTAssertNotNil(nav)
        XCTAssertNotNil(nav?.viewControllers.first as? FilePickerViewController)
    }

    func testSubmitTypeURL() {
        let a = Assignment.make()
        presenter.submitType(.online_url, for: a, button: UIView())
        XCTAssert(router.presented is UrlSubmissionViewController)
    }

    func testSubmitArc() {
        let a = Assignment.make()
        presenter.arcID = .some("4")
        presenter.submitArc(assignment: a)
        let nav = router.presented as? UINavigationController
        XCTAssertNotNil(nav)
        XCTAssertNotNil(nav?.viewControllers.first as? ArcSubmissionViewController)
    }

    func testSubmitTypeBad() {
        let a = Assignment.make()
        presenter.submitType(.on_paper, for: a, button: UIView())
        XCTAssertNil(router.presented)
    }

    func testPickFilesEmptyExtensions() {
        let a = Assignment.make(from: .make(allowed_extensions: [], submission_types: [ .online_upload ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [.online_upload])
        let filePicker = (router.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera, .documentScan])
    }

    func testPickFilesFilesOnly() {
        let a = Assignment.make(from: .make(allowed_extensions: [ "txt" ], submission_types: [ .online_upload ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [ .online_upload ])
        let filePicker = (router.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files])
    }

    func testPickFilesImages() {
        let a = Assignment.make(from: .make(allowed_extensions: [ "jpg" ], submission_types: [ .online_upload ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [ .online_upload ])
        let filePicker = (router.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera, .documentScan])
    }

    func testPickMediaRecordings() {
        let a = Assignment.make(from: .make(allowed_extensions: [], submission_types: [ .online_upload, .media_recording ]))
        presenter.pickFiles(for: a, selectedSubmissionTypes: [ .media_recording ])
        let filePicker = (router.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera, .audio])
    }

    func testRetryFileUpload() {
        XCTAssertNoThrow(presenter.retry(filePicker))
    }

    func testCancelFileUpload() {
        presenter.cancel(filePicker)
        XCTAssertTrue(uploadManager.cancelWasCalled)
    }

    func testCanSubmitFilePicker() throws {
        XCTAssertFalse(presenter.canSubmit(filePicker))
        let url = URL.Directories.temporary.appendingPathComponent("SubmissionButtonPresenterTests-submit-files.txt")
        FileManager.default.createFile(atPath: url.path, contents: "test".data(using: .utf8), attributes: nil)
        try UploadManager.shared.add(url: url, batchID: presenter.batchID)
        let filePicker = FilePickerViewController.create(batchID: presenter.batchID)
        XCTAssertTrue(presenter.canSubmit(filePicker))
    }

    func testCancelAudioRecording() {
        presenter.cancel(audioRecorder)
        XCTAssert(audioRecorder == router.dismissed)
    }

    func testSendAudioRecording() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.send(audioRecorder, url: url)
        XCTAssertNotNil(router.presented)
    }

    func testImagePickerControllerVideo() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.imagePickerController(imagePicker, didFinishPickingMediaWithInfo: [.mediaURL: url])
        XCTAssert(imagePicker == router.dismissed)
    }
}
