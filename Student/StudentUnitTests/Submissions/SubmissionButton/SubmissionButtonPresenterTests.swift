//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Student
@testable import Core
import SafariServices
import TestsFoundation

class SubmissionButtonPresenterTests: PersistenceTestCase {
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
    let fileUploader = MockFileUploader()
    let view = View()

    override func setUp() {
        super.setUp()
        presenter = SubmissionButtonPresenter(env: env, view: view, assignmentID: "1")
        presenter.assignment = Assignment.make([ "submission": Submission.make() ])
        presenter.fileUpload.uploader = fileUploader
    }

    func testButtonText() {
        let a = Assignment.make([
            "submissionTypesRaw": [ "online_upload" ],
            "submission": Submission.make(["workflowStateRaw": "unsubmitted"]),
        ])
        let c = Course.make([ "enrollments": Set([ Enrollment.make() ]) ])
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil), "Submit Assignment")

        a.submission?.workflowState = .submitted
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil), "Resubmit Assignment")

        a.submissionTypes = [ .discussion_topic ]
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil), "View Discussion")

        a.submissionTypes = [ .external_tool ]
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: nil), "Launch External Tool")

        a.submissionTypes = [ .online_quiz ]
        XCTAssertEqual(presenter.buttonText(course: c, assignment: a, quiz: Quiz.make()), "Take Quiz")

        a.submissionTypes = [ .online_upload ]
        a.lockedForUser = true
        XCTAssertNil(presenter.buttonText(course: c, assignment: a, quiz: nil))
    }

    func testSubmitAssignment() {
        let a = Assignment.make([ "submissionTypesRaw": [ "none" ], "submission": Submission.make() ])
        presenter.submitAssignment(a, button: button)
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)

        a.submissionTypes = [ .online_text_entry ]
        presenter.submitAssignment(a, button: button)
        XCTAssert(router.lastRoutedTo(Route.assignmentTextSubmission(courseID: "1", assignmentID: "1", userID: "1")))
    }

    func testSubmitAssignmentChoose() {
        let a = Assignment.make([ "submissionTypesRaw": [ "online_text_entry", "online_url" ], "submission": Submission.make() ])
        presenter.submitAssignment(a, button: button)
        XCTAssert(view.presented is UIAlertController)
        XCTAssert(router.calls.isEmpty)
    }

    func testSubmitTypeMissingSubmission() {
        let a = Assignment.make()
        presenter.submitType(.online_text_entry, for: a)
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)
    }

    func testSubmitTypeLTI() {
        let a = Assignment.make([
            "discussionTopic": DiscussionTopic.make([ "htmlUrl": URL(string: "/discussion") ]),
            "submission": Submission.make(),
        ])
        var asyncDone = expectation(description: "async task complete")
        presenter.submitType(.external_tool, for: a)
        DispatchQueue.main.async { asyncDone.fulfill() }
        wait(for: [asyncDone], timeout: 1)
        XCTAssert(router.viewControllerCalls.isEmpty)

        let request = GetSessionlessLaunchURLRequest(context: ContextModel(.course, id: "1"), id: nil, url: nil, assignmentID: "1", moduleItemID: nil, launchType: .assessment)
        api.mock(request, value: APIGetSessionlessLaunchResponse(id: "", name: "", url: URL(string: "https://instructure.com")!))
        asyncDone = expectation(description: "async task complete")
        presenter.submitType(.external_tool, for: a)
        DispatchQueue.main.async { asyncDone.fulfill() }
        wait(for: [asyncDone], timeout: 1)
        XCTAssert(router.viewControllerCalls.first?.0 is SFSafariViewController)
    }

    func testSubmitTypeDiscussion() {
        let url = URL(string: "/discussion")!
        let a = Assignment.make([
            "discussionTopic": DiscussionTopic.make(),
            "submission": Submission.make(),
        ])
        presenter.submitType(.discussion_topic, for: a)
        XCTAssert(router.calls.isEmpty)

        a.discussionTopic?.htmlUrl = url
        presenter.submitType(.discussion_topic, for: a)
        XCTAssert(router.lastRoutedTo(URL(string: "/discussion")!))
    }

    func testSubmitTypeMedia() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.media_recording, for: a)
        XCTAssert(view.presented is UIAlertController)
    }

    func testSubmitTypeText() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.online_text_entry, for: a)
        XCTAssert(router.lastRoutedTo(Route.assignmentTextSubmission(courseID: "1", assignmentID: "1", userID: "1")))
    }

    func testSubmitTypeQuiz() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.online_quiz, for: a)
        XCTAssert(router.calls.isEmpty) // Not done yet
    }

    func testSubmitTypeUpload() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.online_upload, for: a)
        XCTAssert(view.presented is UINavigationController)
    }

    func testSubmitTypeURL() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.online_url, for: a)
        XCTAssert(router.lastRoutedTo(Route.assignmentUrlSubmission(courseID: "1", assignmentID: "1", userID: "1")))
    }

    func testSubmitTypeBad() {
        let a = Assignment.make([ "submission": Submission.make() ])
        presenter.submitType(.on_paper, for: a)
        XCTAssertNil(view.presented)
        XCTAssert(router.calls.isEmpty)
    }

    func testPickFilesEmptyExtensions() {
        let a = Assignment.make([ "submissionTypesRaw": [ "online_upload" ], "allowedExtensions": [] ])
        presenter.pickFiles(for: a)
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func testPickFilesFilesOnly() {
        let a = Assignment.make([ "submissionTypesRaw": [ "online_upload" ], "allowedExtensions": [ "txt" ] ])
        presenter.pickFiles(for: a)
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files])
    }

    func testPickFilesImages() {
        let a = Assignment.make([ "submissionTypesRaw": [ "online_upload" ], "allowedExtensions": [ "jpg" ] ])
        presenter.pickFiles(for: a)
        let filePicker = (view.presented as? UINavigationController)?.viewControllers.first as? FilePickerViewController
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func testSubmitFiles() {
        let url = URL(fileURLWithPath: "/file.txt")
        try! presenter.fileUpload.addFile(url)
        presenter.submit(filePicker)
        XCTAssert(filePicker.dismissed)
        XCTAssertEqual(fileUploader.uploads.count, 1)
    }

    func testRetryFileUpload() {
        XCTAssertNoThrow(presenter.retry(filePicker))
    }

    func testCancelFileUpload() {
        let url = URL(fileURLWithPath: "/file.txt")
        try! presenter.fileUpload.addFile(url)
        presenter.cancel(filePicker)
        XCTAssertEqual(fileUploader.cancels.count, 1)
    }

    func testCanSubmitFilePicker() {
        let url = URL(fileURLWithPath: "/file.txt")
        let filePicker = FilePickerViewController.create(environment: env, batchID: presenter.fileUpload.batchID)
        XCTAssertFalse(presenter.canSubmit(filePicker))
        try! presenter.fileUpload.addFile(url)
        XCTAssertTrue(presenter.canSubmit(filePicker))
    }

    func testPickMediaRecordingType() {
        presenter.pickMediaRecordingType()
        XCTAssert(view.presented is UIAlertController)
    }

    func testCancelAudioRecording() {
        presenter.cancel(audioRecorder)
        XCTAssert(audioRecorder.dismissed)
    }

    func testSendAudioRecording() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.send(audioRecorder, url: url)
        XCTAssertNotNil(view.presented)
    }

    func testImagePickerControllerVideo() {
        let url = URL(string: "data:audio/x-aac,")!
        presenter.imagePickerController(imagePicker, didFinishPickingMediaWithInfo: [.mediaURL: url])
        XCTAssert(imagePicker.dismissed)
    }
}
