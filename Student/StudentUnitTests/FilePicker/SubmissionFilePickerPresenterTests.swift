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
    lazy var testImage: UIImage = {
        return UIImage(named: "TestImage.png", in: Bundle(for: SubmissionFilePickerPresenterTests.self), compatibleWith: nil)!
    }()
    var testImageURL: URL {
        return try! testImage.write()
    }

    let view = FilePickerView()
    var presenter: SubmissionFilePresenter!
    let onUpdateExpectation = XCTestExpectation(description: "on update")
    let uploader = MockFileUploader()

    var assignment: Assignment!

    override func setUp() {
        super.setUp()
        presenter = SubmissionFilePresenter(env: env, fileUploader: uploader, courseID: courseID, assignmentID: assignmentID, userID: userID)
        presenter.view = view
        view.presenter = presenter
        view.onUpdate = onUpdateExpectation.fulfill
        assignment = Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": [],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
    }

    func testSourcesAllowedExtensions() {
        assignment.allowedExtensions = ["png", "jpg"]
        try! databaseClient.save()
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testSourcesAny() {
        assignment.allowedExtensions = []
        try! databaseClient.save()
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testSourcesExcludesCameraAndLibraryIfPhotosAndVideosNotAllowed() {
        assignment.allowedExtensions = ["txt"]
        try! databaseClient.save()

        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), false)
        XCTAssertEqual(view.sources?.contains(.library), false)
        XCTAssertEqual(view.sources?.contains(.files), true)

    }

    func testSourcesIncludesCameraAndLibraryIfAllowsVideos() {
        assignment.allowedExtensions = ["mov"]
        try! databaseClient.save()
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.sources?.contains(.camera), true)
        XCTAssertEqual(view.sources?.contains(.library), true)
        XCTAssertEqual(view.sources?.contains(.files), true)
    }

    func testAddCreatesFileSubmission() {
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        XCTAssertEqual(presenter.files.count, 1)
    }

    func testAddFromSourceCamera() {
        presenter.viewIsReady()
        presenter.add(fromSource: .camera)
        XCTAssertEqual(view.presentCameraCallCount, 1)
    }

    func testAddFromSourceFiles() {
        assignment.allowedExtensions = ["png", "mov", "mp3", "txt"]
        try! databaseClient.save()

        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        presenter.add(fromSource: .files)
        XCTAssertEqual(view.presentedDocumentTypes, ["public.png", "com.apple.quicktime-movie", "public.mp3", "public.plain-text"])
    }

    func testAddFromSourceLibrary() {
        presenter.viewIsReady()
        presenter.add(fromSource: .library)
        XCTAssertEqual(view.presentLibraryCallCount, 1)
    }

    func testAddWithCameraResult() {
        Clock.mockNow(Date.isoDateFromString("2018-11-15T17:44:54Z")!)
        let expected = URL.temporaryDirectory.appendingPathComponent("images").appendingPathComponent("1542303894.0.png")
        presenter.viewIsReady()
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.originalImage] = testImage
        let expectation = XCTestExpectation(description: "update files")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(view.files?.first?.localFileURL, expected)
        XCTAssertEqual(view.files?.first?.size, 17308)
    }

    func testCameraDidCaptureVideo() {
        let url = try! testImage.write(nameIt: "crappy-name")
        let expected = URL.temporaryDirectory.appendingPathComponent("videos").appendingPathComponent("1542303894.0.png")
        Clock.mockNow(Date.isoDateFromString("2018-11-15T17:44:54Z")!)
        presenter.viewIsReady()
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.mediaURL] = url
        let expectation = XCTestExpectation(description: "on update")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.files?.first?.localFileURL, expected)
    }

    func testCancelSubmissionDeletesFilesAndDismisses() {
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let cancel = view.navigationItems!.left[0]
        cancel.performAction()
        XCTAssert(presenter.files.isEmpty)
        XCTAssertTrue(view.dismissed)
    }

    // FIXME: EXC_BAD_ACCESS on uploader
    func xtestSubmitStartsFileUpload() {
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let uploading = XCTestExpectation(description: "file uploading")
        view.onUpdate = {
            if self.uploader.uploads.count == 1 {
                uploading.fulfill()
            }
        }
        let dismissed = XCTestExpectation(description: "view dismissed")
        view.onDismissed = dismissed.fulfill
        let submit = view.navigationItems!.right[0]
        submit.performAction()
        wait(for: [uploading, dismissed], timeout: 0.1)
    }

    // FIXME: EXC_BAD_ACCESS on uploader
    func xtestSubmitShowsUploadError() {
        uploader.error = NSError.instructureError("error")
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let uploading = XCTestExpectation(description: "file uploading")
        view.onUpdate = {
            if self.uploader.uploads.count == 1 {
                uploading.fulfill()
            }
        }
        let error = XCTestExpectation(description: "view error")
        view.onError = error.fulfill
        let submit = view.navigationItems!.right[0]
        submit.performAction()
        wait(for: [uploading, error], timeout: 0.1)
    }

    func testSelectFileShowsError() {
        let file = File.make()
        file.uploadError = "Something went wrong"
        let expectation = XCTestExpectation(description: "view onError")
        view.onError = expectation.fulfill
        presenter.didSelectFile(file)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.error?.localizedDescription, "Something went wrong")
    }

    func testInProgressMinimum() {
        File.make(["bytesSent": 0, "assignmentID": assignmentID, "taskIDRaw": 1])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.progress, 0.02)
    }

    func testInProgressMaximum() {
        File.make(["bytesSent": 1, "size": 1, "assignmentID": assignmentID, "taskIDRaw": 1])
        presenter.viewIsReady()
        wait(for: [onUpdateExpectation], timeout: 0.1)
        XCTAssertEqual(view.progress, 0.98)
    }
}
