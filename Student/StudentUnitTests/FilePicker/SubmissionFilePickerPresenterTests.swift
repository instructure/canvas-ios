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
    lazy var uploader = MockFileUploader(appGroup: .student, environment: .shared)

    var assignment: Assignment!

    override func setUp() {
        super.setUp()
        presenter = SubmissionFilePresenter(env: env, fileUploader: uploader, courseID: courseID, assignmentID: assignmentID, userID: userID)
        presenter.view = view
        view.onUpdate = onUpdateExpectation.fulfill
        assignment = Assignment.make([
            "id": assignmentID,
            "courseID": courseID,
            "allowedExtensions": [],
            "submissionTypesRaw": [SubmissionType.online_upload.rawValue],
        ])
        try! assignment.removeSubmissionFiles(appGroup: .student)
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
        XCTAssert(assignment.hasFileSubmission)
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
        let expected = assignment.fileSubmissionURL(appGroup: .student).appendingPathComponent("1542303894.0.png")
        presenter.viewIsReady()
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.originalImage] = testImage
        let expectation = XCTestExpectation(description: "update files")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(view.files?.first?.url, expected)
        XCTAssertEqual(view.files?.first?.size, 17308)
    }

    func testCameraDidCaptureVideo() {
        let url = try! testImage.write(nameIt: "crappy-name")
        let expected = assignment.fileSubmissionURL(appGroup: .student).appendingPathComponent("1542303894.0.png")
        Clock.mockNow(Date.isoDateFromString("2018-11-15T17:44:54Z")!)
        presenter.viewIsReady()
        var info: CameraCaptureResult = CameraCaptureResult()
        info[UIImagePickerController.InfoKey.mediaURL] = url
        let expectation = XCTestExpectation(description: "on update")
        view.onUpdate = expectation.fulfill
        presenter.add(withCameraResult: info)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.files?.first?.url, expected)
    }

    func testCancelSubmissionDeletesSubmissionAndDismisses() {
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        wait(for: [onUpdateExpectation], timeout: 0.1)
        let cancel = view.navigationItems!.left[0]
        cancel.performAction()
        XCTAssertFalse(assignment.hasFileSubmission)
        XCTAssertTrue(view.dismissed)
    }

    func testSubmitStartsFileUpload() {
        presenter.viewIsReady()
        presenter.add(fromURL: testImageURL)
        let uploading = XCTestExpectation(description: "file uploading")
        view.onUpdate = {
            if self.uploader.numberOfUploads == 1 {
                uploading.fulfill()
            }
        }
        let submit = view.navigationItems!.right[0]
        submit.performAction()
        wait(for: [uploading], timeout: 0.1)
    }

    func testCancelFailedSubmission() {
    }
}
