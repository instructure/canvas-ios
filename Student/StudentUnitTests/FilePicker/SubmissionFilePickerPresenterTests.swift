//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
@testable import Student
import TestsFoundation
@testable import Core

class SubmissionFilePickerPresenterTests: PersistenceTestCase {
    let courseID = "1"
    let assignmentID = "2"
    let userID = "3"
    let useCase = { () -> AsyncOperation in
        return AsyncBlockOperation { finished in
            finished(nil)
        }
    }
    lazy var testFile: URL = {
        let bundle = Bundle(for: type(of: self))
        return bundle.url(forResource: "Info", withExtension: "plist")!
    }()

    let view = FilePickerView()
    var presenter: SubmissionFilePresenter!
    let onUpdateExpectation = XCTestExpectation(description: "on update")

    override func setUp() {
        super.setUp()
        presenter = SubmissionFilePresenter(env: env, courseID: courseID, assignmentID: assignmentID, userID: userID, useCase: useCase)
        presenter.view = view
        view.onUpdate = onUpdateExpectation.fulfill
    }

    func testSourcesAllowedExtensions() {
        Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": ["png", "jpg"],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testSourcesAny() {
        Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": [],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testSourcesExcludesCameraAndLibraryIfPhotosAndVideosNotAllowed() {
        Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": ["txt"],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), false)
        XCTAssertEqual(view.sources?.contains(.library), false)
        XCTAssertEqual(view.sources?.contains(.files), true)

    }

    func testSourcesIncludesCameraAndLibraryIfAllowsVideos() {
        Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": ["mov"],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testChangedFilesFromServer() {
        let expectation = XCTestExpectation(description: "changedFiles")
        let useCase = { () -> AsyncOperation in
            return DatabaseOperation(database: self.env.database) { client in
                self.view.onUpdate = expectation.fulfill
                Assignment.make([
                    "id": self.assignmentID,
                    "courseID": self.courseID,
                    "allowedExtensions": ["png", "jpg"],
                    "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
                ], client: client)
            }
        }
        presenter = SubmissionFilePresenter(env: env, courseID: courseID, assignmentID: assignmentID, userID: userID, useCase: useCase)
        presenter.view = view
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 3)
        XCTAssertEqual(view.sources?.count, 3)
    }

    func testAddQueuesFileUpload() {
        Assignment.make(["id": assignmentID])
        presenter.add(fromURL: testFile)
        env.queue.waitUntilAllOperationsAreFinished()
        let fileUploads: [FileUpload] = databaseClient.fetch()
        XCTAssertEqual(fileUploads.count, 1)
        XCTAssertNotNil(fileUploads.first?.submission)
    }

    func testAddFromSourceCamera() {
        Assignment.make(["id": assignmentID])
        presenter.add(fromSource: .camera)
        XCTAssertEqual(view.presentCameraCallCount, 1)
    }

    func testAddFromSourceFiles() {
        Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": ["png", "mov", "mp3", "txt"],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        presenter.add(fromSource: .files)
        XCTAssertEqual(view.presentedDocumentTypes, ["public.png", "com.apple.quicktime-movie", "public.mp3", "public.plain-text"])
    }

    func testAddFromSourceLibrary() {
        Assignment.make(["id": assignmentID])
        presenter.viewIsReady()
        presenter.add(fromSource: .library)
        XCTAssertEqual(view.presentLibraryCallCount, 1)
    }

    func testAddWithCameraResult() {
        Assignment.make(["id": assignmentID])
        let expected = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/1542303894.0-submission.png")
        Clock.mockNow(Date.isoDateFromString("2018-11-15T17:44:54Z")!)
        presenter.viewIsReady()
        let testImage = UIImage(named: "TestImage.png", in: Bundle(for: SubmissionFilePickerPresenterTests.self), compatibleWith: nil)
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.originalImage] = testImage
        let expectation = XCTestExpectation(description: "update files")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        env.queue.waitUntilAllOperationsAreFinished()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(view.files?.first?.url, expected)
        XCTAssertEqual(view.files?.first?.size, 17308)
    }

    func testCameraDidCaptureVideo() {
        Assignment.make(["id": assignmentID])
        let expected = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/1542303894.0-submission.MOV")
        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/original.MOV")
        Clock.mockNow(Date.isoDateFromString("2018-11-15T17:44:54Z")!)
        let testImage = UIImage(named: "TestImage.png", in: Bundle(for: SubmissionFilePickerPresenterTests.self), compatibleWith: nil)!
        addTempFile(testImage, toURL: url)
        presenter.viewIsReady()
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.mediaURL] = url
        let expectation = XCTestExpectation(description: "on update")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        env.queue.waitUntilAllOperationsAreFinished()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.files?.first?.url, expected)
    }

    func testCancelSubmissionDeletesSubmission() {
        let assignment = Assignment.make(["id": assignmentID])
        let submission = FileSubmission.make(["assignment": assignment])
        XCTAssertEqual(assignment.fileSubmission, submission)
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let cancel = view.navigationItems!.left[0]
        cancel.performAction()
        env.queue.waitUntilAllOperationsAreFinished()
        databaseClient.refresh()
        XCTAssertNil(assignment.fileSubmission)
    }

    func testSubmitStartsFileUpload() {
        queueUploadAndSubmit()

        databaseClient.refresh()
        let fileUploads: [FileUpload] = databaseClient.fetch()
        XCTAssertEqual(fileUploads.count, 1)
        XCTAssertEqual(fileUploads.first?.backgroundSessionID, api.identifier)
        XCTAssertEqual(fileUploads.first?.taskID, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.count, 1)
        XCTAssertEqual(backgroundAPI.uploadMocks.values.first?.resumeCount, 1)
    }

    func testDismissWhileUploadInProgressDoesNotDeleteSubmission() {
        let assignment = Assignment.make(["id": assignmentID])
        let submission = FileSubmission.make(["assignment": assignment, "started": true])
        XCTAssertEqual(assignment.fileSubmission, submission)
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let done = view.navigationItems!.right[0]
        done.performAction()
        env.queue.waitUntilAllOperationsAreFinished()
        databaseClient.refresh()
        XCTAssertNotNil(assignment.fileSubmission)
        XCTAssertTrue(view.dismissed)
    }

    func testFileSubmissionError() {
        let assignment = Assignment.make(["id": assignmentID])
        let submission = FileSubmission.make(["assignment": assignment, "error": "very special error"])
        let upload = FileUpload.make(["submission": submission, "error": nil])
        submission.addToFileUploads(upload)
        presenter.viewIsReady()

        let expectation = BlockExpectation(description: "files refresh") { self.view.files?.first?.error == "very special error" }

        wait(for: [expectation], timeout: 2)
    }

    private func queueUploadAndSubmit() {
        Assignment.make(["id": assignmentID])
        mockAPI()
        presenter.viewIsReady()
        let info = FileInfo(url: testFile, size: 120)
        presenter.add(withInfo: info)
        env.queue.waitUntilAllOperationsAreFinished()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let submit = view.navigationItems!.right[0]
        submit.performAction()
        env.queue.waitUntilAllOperationsAreFinished()
    }

    private func mockAPI() {
        let body = PostFileUploadTargetRequest.Body(
            name: testFile.lastPathComponent,
            on_duplicate: .rename,
            parent_folder_id: nil
        )
        let request = PostFileUploadTargetRequest(
            target: .submission(courseID: "1", assignmentID: assignmentID),
            body: body
        )
        let response = PostFileUploadTargetRequest.Response.init(upload_url: URL(string: "s3://somewhere.com/bucket/1")!, upload_params: [:])
        api.mock(request, value: response)
    }

    @discardableResult
    private func addTempFile(_ image: UIImage, toURL url: URL) -> Int64 {
        guard let data = image.pngData() else { return 0 }
        try? data.write(to: url, options: Data.WritingOptions.atomicWrite)
        return Int64(data.count)
    }
}
