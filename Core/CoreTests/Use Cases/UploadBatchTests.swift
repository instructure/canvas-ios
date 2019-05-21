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

import XCTest
@testable import Core
import TestsFoundation

class UploadBatchTests: CoreTestCase {
    func testStateEquatable() {
        XCTAssertEqual(UploadBatch.State.staged, .staged)
        XCTAssertEqual(UploadBatch.State.uploading, .uploading)
        XCTAssertEqual(UploadBatch.State.failed(NSError.instructureError("lhs")), .failed(NSError.instructureError("rhs")))
        XCTAssertEqual(UploadBatch.State.completed(fileIDs: ["1", "2"]), .completed(fileIDs: ["2", "1"]))
        XCTAssertNotEqual(UploadBatch.State.completed(fileIDs: ["1"]), .completed(fileIDs: ["2"]))
        XCTAssertNotEqual(UploadBatch.State.staged, .uploading)
    }

    func testStateCompleted() {
        XCTAssertTrue(UploadBatch.State.completed(fileIDs: []).completed)
        XCTAssertFalse(UploadBatch.State.staged.completed)
        XCTAssertFalse(UploadBatch.State.uploading.completed)
        XCTAssertFalse(UploadBatch.State.failed(NSError.instructureError("error")).completed)
    }

    func testStateFailed() {
        XCTAssertTrue(UploadBatch.State.failed(NSError.instructureError("error")).failed)
        XCTAssertFalse(UploadBatch.State.completed(fileIDs: []).failed)
        XCTAssertFalse(UploadBatch.State.staged.failed)
        XCTAssertFalse(UploadBatch.State.uploading.failed)
    }

    func testInitWithCallback() {
        File.make(["batchID": "1", "id": nil])
        let expectation = self.expectation(description: "callback")
        expectation.assertForOverFulfill = false
        var state: UploadBatch.State?
        _ = UploadBatch(environment: environment, batchID: "1") {
            state = $0
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(state, .staged)
    }

    func testSubscribeNilState() {
        let expectation = self.expectation(description: "nil state")
        expectation.assertForOverFulfill = false
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == nil {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.1)
    }

    func testSubscribeCompletedState() {
        let expectation = self.expectation(description: "completed state")
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .completed(fileIDs: ["1"]) {
                expectation.fulfill()
            }
        }
        File.make(["batchID": "1", "id": "1"])
        wait(for: [expectation], timeout: 0.1)
    }

    func testSubscribeFailedState() {
        let error = NSError.instructureError("doh")
        let expectation = self.expectation(description: "error state")
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .failed(error) {
                expectation.fulfill()
            }
        }
        File.make(["batchID": "1", "uploadError": error.localizedDescription, "id": nil])
        wait(for: [expectation], timeout: 0.1)
    }

    func testSubscribeUploadingState() {
        let expectation = self.expectation(description: "uploading state")
        expectation.assertForOverFulfill = false
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .uploading {
                expectation.fulfill()
            }
        }
        File.make(["batchID": "1", "taskIDRaw": 1, "id": nil])
        wait(for: [expectation], timeout: 0.1)
    }

    func testSubscribeStagedState() {
        let expectation = self.expectation(description: "staged state")
        expectation.assertForOverFulfill = false
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .staged {
                expectation.fulfill()
            }
        }
        File.make(["batchID": "1", "taskIDRaw": nil, "id": nil, "uploadError": nil])
        wait(for: [expectation], timeout: 0.1)
    }

    func testSubscribeOnlyGetsCompletedOnce() {
        let expectation = self.expectation(description: "completed more than once")
        expectation.assertForOverFulfill = true
        expectation.isInverted = true
        expectation.expectedFulfillmentCount = 2
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .completed(fileIDs: ["1"]) {
                expectation.fulfill()
            }
        }
        let file = File.make(["batchID": "1", "id": "1"])
        file.size = 2 // trigger update
        try! databaseClient.save()
        wait(for: [expectation], timeout: 0.5)
    }

    func testSubscribeOnlyGetsFailedOnce() {
        let expectation = self.expectation(description: "failed more than once")
        expectation.assertForOverFulfill = true
        expectation.isInverted = true
        expectation.expectedFulfillmentCount = 2
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        batch.subscribe {
            if $0 == .completed(fileIDs: ["1"]) {
                expectation.fulfill()
            }
        }
        let file = File.make(["batchID": "1", "uploadError": "doh"])
        file.size = 2 // trigger update
        try! databaseClient.save()
        wait(for: [expectation], timeout: 0.5)
    }

    func testAddFile() throws {
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        let url = URL(string: "data:audio/x-aac,")!
        try batch.addFile(url)
        let files: [File] = databaseClient.fetch()
        let file = files.first
        XCTAssertNotNil(file)
        XCTAssertEqual(file?.batchID, "1")
        XCTAssertEqual(file?.size, 0)
        XCTAssertEqual(file?.localFileURL, url)
    }

    func testUpload() throws {
        let expectation = self.expectation(description: "callback uploading")
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        let uploader = MockFileUploader()
        batch.uploader = uploader
        let url = URL(string: "data:audio/x-aac,")!
        try batch.addFile(url)
        batch.upload(to: .course("1")) { state in
            if state == .uploading {
                expectation.fulfill()
            }
        }
        let files: [File] = databaseClient.fetch()
        let file = files.first
        XCTAssertNotNil(file)
        file?.taskID = 1
        try databaseClient.save()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(uploader.uploads.count, 1)
    }

    func testCancel() throws {
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        let uploader = MockFileUploader()
        batch.uploader = uploader
        let url = URL(string: "data:audio/x-aac,")!
        try batch.addFile(url)
        batch.cancel()
        XCTAssertEqual(uploader.cancels.count, 1)
    }
}
