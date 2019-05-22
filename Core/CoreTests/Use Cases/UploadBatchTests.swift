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

    func testUploadError() throws {
        let expectation = self.expectation(description: "upload error")
        let error = NSError.instructureError("doh")
        let batch = UploadBatch(environment: environment, batchID: "1", callback: nil)
        let uploader = MockFileUploader()
        uploader.error = error
        let url = URL(string: "data:audio/x-aac,")!
        try batch.addFile(url)
        batch.uploader = uploader
        batch.upload(to: .course("1")) { state in
            if state == .failed(error) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 0.5)
    }
}
