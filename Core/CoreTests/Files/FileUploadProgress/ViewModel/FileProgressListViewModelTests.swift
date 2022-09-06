//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest
import CoreData

class MockDelegate: FileProgressListViewModelDelegate {
    private(set) var cancelCalled = false
    private(set) var retryCalled = false
    private(set) var deleteCalled = false

    func fileProgressViewModelCancel(_ viewModel: FileProgressListViewModel) {
        cancelCalled = true
    }

    func fileProgressViewModelRetry(_ viewModel: FileProgressListViewModel) {
        retryCalled = true
    }

    func fileProgressViewModel(_ viewModel: FileProgressListViewModel, delete fileUploadItemID: NSManagedObjectID) {
        deleteCalled = true
    }
}

class FileProgressListViewModelTests: CoreTestCase {
    private var submission: FileSubmission!
    private let presentingViewController = UIViewController()
    private var testee: FileProgressListViewModel!
    private var mockDelegate: MockDelegate!
    private var dismissCalled = false

    override func setUp() {
        super.setUp()
        mockDelegate = MockDelegate()

        submission = databaseClient.insert() as FileSubmission
        submission.assignmentID = ""
        submission.courseID = ""
        saveFiles()

        testee = FileProgressListViewModel(submissionID: submission.objectID, environment: environment, dismiss: { [weak self] in
            self?.dismissCalled = true
        })
        dismissCalled = false
        testee.delegate = mockDelegate
    }

    func testTitle() {
        XCTAssertEqual(testee.title, "Submission")
    }

    func testWaitingState() {
        makeFile()
        makeFile()
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .waiting)
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertNil(testee.rightBarButton)
    }

    func testOneFileFinishedOtherIsUploading() {
        let file1 = makeFile()
        file1.apiID = "uploadedId"
        file1.bytesUploaded = file1.fileSize
        makeFile()
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 10 bytes of 20 bytes", progress: 0.5))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Dismiss")
    }

    func testOneFileFailedOtherIsUploading() {
        let file1 = makeFile()
        file1.uploadError = "error"
        file1.bytesUploaded = 5
        let file2 = makeFile()
        file2.bytesUploaded = 5
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        // A finished file is considered completed, that's why the 15 bytes uploaded.
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 15 bytes of 20 bytes", progress: 0.75))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Dismiss")
    }

    func testOneFileFailedOtherSucceeded() {
        let file1 = makeFile()
        file1.bytesUploaded = 5
        file1.uploadError = "error"
        let file2 = makeFile()
        file2.bytesUploaded = 10
        file2.apiID = "uploadedId"
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .failed(message: "One or more files failed to upload. Check your internet connection and retry to submit.", error: nil))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Retry")
    }

    func testBothFilesUploaded() {
        let file1 = makeFile()
        file1.bytesUploaded = 10
        file1.apiID = "uploadedId"
        let file2 = makeFile()
        file2.bytesUploaded = 10
        file2.apiID = "uploadedId"
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 20 bytes of 20 bytes", progress: 1))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Dismiss")
    }

    func testFileIsUploadedButSubmissionFailed() {
        let file = makeFile()
        file.bytesUploaded = 10
        file.apiID = "uploadedId"
        submission.submissionError = "apierror"
        saveFiles()

        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.state, .failed(message: "Your file was successfully uploaded but the submission to the assignment failed.", error: "apierror"))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Retry")
    }

    func testFilesAreUploadedButSubmissionFailed() {
        let file1 = makeFile()
        file1.bytesUploaded = 10
        file1.apiID = "uploadedId"
        let file2 = makeFile()
        file2.bytesUploaded = 10
        file2.apiID = "uploadedId"
        submission.submissionError = "apierror"
        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .failed(message: "Your files were successfully uploaded but the submission to the assignment failed.", error: "apierror"))
        XCTAssertEqual(testee.leftBarButton?.title, "Cancel")
        XCTAssertEqual(testee.rightBarButton?.title, "Retry")
    }

    func testBothFilesUploadedAndSubmissionCompleted() {
        let file1 = makeFile()
        file1.bytesUploaded = 10
        file1.apiID = "uploadedId"
        let file2 = makeFile()
        file2.bytesUploaded = 10
        file2.apiID = "uploadedId"
        submission.isSubmitted = true

        saveFiles()

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.state, .success)
        XCTAssertNil(testee.leftBarButton)
        XCTAssertEqual(testee.rightBarButton?.title, "Done")
    }

    func testUpdatesProgress() {
        let file = makeFile()
        saveFiles()
        XCTAssertEqual(testee.state, .waiting)

        let uiRefreshExpectation = expectation(description: "UI refresh trigger received")
        uiRefreshExpectation.assertForOverFulfill = false
        let uiRefreshObserver = testee.objectWillChange.sink { _ in
            uiRefreshExpectation.fulfill()
        }
        file.bytesUploaded = 1
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 1 byte of 10 bytes", progress: 0.1))

        uiRefreshObserver.cancel()
    }

    func testClampsProgressToOneWhenMoreBytesUploadedThanExpected() {
        let file = makeFile()
        file.bytesUploaded = file.fileSize + 1
        saveFiles()
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 10 bytes of 10 bytes", progress: 1))
    }

    // MARK: Navigation Bar Actions

    func testDismissDuringUpload() {
        let fileItem = makeFile()
        fileItem.bytesUploaded = 1 // dismiss only available when upload started
        saveFiles()

        testee.rightBarButton?.action()
        XCTAssertTrue(dismissCalled)
    }

    func testDoneOnSucceeded() {
        let file = makeFile()
        file.apiID = "uploadedId"
        saveFiles()

        testee.rightBarButton?.action()
        XCTAssertTrue(dismissCalled)
    }

    func testRetryOnUploadFailure() {
        let file = makeFile()
        file.uploadError = "error"
        saveFiles()

        testee.rightBarButton?.action()
        XCTAssertTrue(mockDelegate.retryCalled)
    }

    func testCancelDialogPropertiesDuringUpload() {
        let file = makeFile()
        file.bytesUploaded = 1
        saveFiles()
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 1 byte of 10 bytes", progress: 0.1))

        var receivedAlert: UIAlertController?
        let alertSubscription = testee.presentDialog.sink { alert in
            receivedAlert = alert
        }
        testee.leftBarButton?.action()

        guard let alert = receivedAlert else {
            XCTFail("No cancel dialog.")
            return
        }

        XCTAssertEqual(alert.title, "Cancel Submission?")
        XCTAssertEqual(alert.message, "This will cancel and delete your upload.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Yes")
        XCTAssertEqual(alert.actions[0].style, .destructive)
        XCTAssertEqual(alert.actions[1].title, "No")
        XCTAssertEqual(alert.actions[1].style, .cancel)
        alertSubscription.cancel()
    }

    func testCancelDialogConfirmationDuringUpload() {
        let file = makeFile()
        file.bytesUploaded = 1
        saveFiles()
        XCTAssertEqual(testee.state, .uploading(progressText: "Uploading 1 byte of 10 bytes", progress: 0.1))

        var receivedAlert: UIAlertController?
        let alertSubscription = testee.presentDialog.sink { alert in
            receivedAlert = alert
        }
        var dismissReceived = false
        let dismissSubscription = testee.dismiss.sink { completion in
            dismissReceived = true
            completion()
        }
        testee.leftBarButton?.action()

        guard let alert = receivedAlert else {
            XCTFail("No cancel dialog.")
            return
        }

        (alert.actions[0] as? AlertAction)!.handler!(alert.actions[0])
        XCTAssertTrue(dismissReceived)
        XCTAssertTrue(mockDelegate.cancelCalled)
        alertSubscription.cancel()
        dismissSubscription.cancel()
    }

    // MARK: Item Deletion

    func testDeleteSingleFileDialogProperties() {
        let file = makeFile()
        file.uploadError = "asd"
        saveFiles()
        XCTAssertEqual(testee.state, .failed(message: "One or more files failed to upload. Check your internet connection and retry to submit.", error: nil))

        var receivedAlert: UIAlertController?
        let alertSubscription = testee.presentDialog.sink { alert in
            receivedAlert = alert
        }
        testee.items[0].remove()

        guard let alert = receivedAlert else {
            XCTFail("No cancel dialog.")
            return
        }

        XCTAssertFalse(mockDelegate.deleteCalled)
        XCTAssertEqual(alert.title, "Remove From List?")
        XCTAssertEqual(alert.message, "This will cancel and delete your upload.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(alert.actions[0].title, "Yes")
        XCTAssertEqual(alert.actions[0].style, .destructive)
        XCTAssertEqual(alert.actions[1].title, "No")
        XCTAssertEqual(alert.actions[1].style, .cancel)
        alertSubscription.cancel()
    }

    func testDeleteSingleFileDialogConfirmation() {
        let file = makeFile()
        file.uploadError = "asd"
        saveFiles()
        XCTAssertEqual(testee.state, .failed(message: "One or more files failed to upload. Check your internet connection and retry to submit.", error: nil))

        var receivedAlert: UIAlertController?
        let alertSubscription = testee.presentDialog.sink { alert in
            receivedAlert = alert
        }
        testee.items[0].remove()

        guard let alert = receivedAlert else {
            XCTFail("No cancel dialog.")
            return
        }

        var dismissReceived = false
        let dismissSubscription = testee.dismiss.sink { completion in
            dismissReceived = true
            completion()
        }

        (alert.actions[0] as? AlertAction)!.handler!(alert.actions[0])
        XCTAssertTrue(dismissReceived)
        XCTAssertTrue(mockDelegate.deleteCalled)
        alertSubscription.cancel()
        dismissSubscription.cancel()
    }

    // MARK: Helpers

    @discardableResult
    private func makeFile() -> FileUploadItem {
        let file = databaseClient.insert() as FileUploadItem
        file.bytesToUpload = 10
        file.fileSize = 10
        file.localFileURL = URL(string: "/file")!
        file.fileSubmission = submission
        return file
    }

    private func saveFiles() {
        try! databaseClient.save()
    }
}
