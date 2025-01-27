//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Combine
@testable import Core
import TestsFoundation
import CoreData
import XCTest

class AttachmentPickerInteractorLiveTests: CoreTestCase {
    var testee: AttachmentPickerInteractorLive!

    private let batchId: String = "testBatchId"
    private let file1 = File.make(from: .make(
        id: "p1",
        display_name: "PDF File 1",
        contentType: "application/pdf",
        url: URL(string: "/files/d?download=1")!,
        mime_class: "pdf"
    ))
    private let file2 = File.make(from: .make(
        id: "p2",
        display_name: "PDF File 2",
        contentType: "application/pdf",
        url: URL(string: "/files/d?download=2")!,
        mime_class: "pdf"
    ))
    private let alreadyUploadedFiles = CurrentValueSubject<[File], Never>([])

    override func setUp() {
        super.setUp()
        testee = AttachmentPickerInteractorLive(batchId: batchId, uploadManager: uploadManager, alreadyUploadedFiles: alreadyUploadedFiles)
    }

    func testAddFile() {
        testee.addFile(url: file1.url!)
        XCTAssertTrue(uploadManager.addWasCalled)
    }

    func testUpload() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)
        testee.uploadFiles()
        XCTAssertTrue(file2.isUploaded)
    }

    func testCancel() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)

        testee.cancel()
    }

    func testRetry() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)
        testee.retry()
        XCTAssertTrue(file2.isUploaded)
    }

    func testAddFileFromOnlineStore() {
        let file = File.make()
        var addesFiles: [File] = []
        let expectation = self.expectation(description: "addFile")
        var subscriptions: [AnyCancellable] = []

        testee.addFile(file: file)
        alreadyUploadedFiles
            .sink { files in
                addesFiles = files
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(addesFiles, [file])
    }

    func testRemoveFile() {
        let file = File.make()
        var addesFiles: [File] = []
        let expectation = self.expectation(description: "addFile")
        var subscriptions: [AnyCancellable] = []
        testee.addFile(file: file)
        testee.addFile(url: file1.url!)

        testee.removeFile(file: file)

        alreadyUploadedFiles
            .sink { files in
                addesFiles = files
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(addesFiles, [])
    }

    func testDeleteFile() {
        let apiFile = APIFile.make()
        let file = File.make(from: apiFile)
        testee.addFile(file: file)
        testee.addFile(url: file1.url!)
        let deleteRequest = DeleteFileRequest(fileID: file.id!)
        api.mock(deleteRequest, value: apiFile)

        XCTAssertFinish(testee.deleteFile(file: file))
        waitForState(.data)
    }

    func testIsCancelDialogNeeded() {
        XCTAssertFalse(testee.isCancelConfirmationNeeded)
        let file = File.make()
        testee.addFile(file: file)
        file.taskID = "1"
        XCTAssertTrue(testee.isCancelConfirmationNeeded)
        testee.uploadFiles()
        file.taskID = nil
        XCTAssertFalse(testee.isCancelConfirmationNeeded)
    }

    private func waitForState(_ state: StoreState) {
        let stateUpdate = expectation(description: "Expected state reached")
        stateUpdate.assertForOverFulfill = false
        stateUpdate.fulfill()
        wait(for: [stateUpdate], timeout: 1)
    }
}
