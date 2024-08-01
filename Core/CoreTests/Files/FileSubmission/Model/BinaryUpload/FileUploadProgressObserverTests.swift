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

class FileUploadProgressObserverTests: CoreTestCase {
    private lazy var mockTask = api.urlSession.dataTask(with: .stub)

    // MARK: - Receive Progress Update

    func testUpdatesUploadedAndTotalSize() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        XCTAssertEqual(uploadItem.bytesToUpload, 0)
        XCTAssertEqual(uploadItem.bytesUploaded, 0)
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)

        testee.urlSession(api.urlSession, task: mockTask, didSendBodyData: 0, totalBytesSent: 1, totalBytesExpectedToSend: 10)

        XCTAssertEqual(uploadItem.bytesUploaded, 1)
        XCTAssertEqual(uploadItem.bytesToUpload, 10)
    }

    // MARK: - Successful Completion

    func testUpdatesFileIDOnSuccessfulBodyResponse() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        XCTAssertNil(uploadItem.apiID)
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let apiResponse = try! encoder.encode(APIFile.make(id: "testAPIID"))
        let completionExpectation = expectation(description: "completion got signalled")
        let valueExpectation = expectation(description: "received value")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure = completion {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in
            valueExpectation.fulfill()
        }

        testee.urlSession(api.urlSession, dataTask: mockTask, didReceive: apiResponse)
        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(uploadItem.apiID, "testAPIID")
        XCTAssertNil(uploadItem.uploadError)

        subscription.cancel()
    }

    // MARK: - Failures

    func testWritesErrorToUploadItem() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let valueExpectation = expectation(description: "received value")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure = completion {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in
            valueExpectation.fulfill()
        }

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: NSError.instructureError("Test Error"))

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(uploadItem.uploadError, "Test Error")
        subscription.cancel()
    }

    func testCreatesErrorIfTaskCompletesWithoutReceivingHttpBody() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let valueExpectation = expectation(description: "received value")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure = completion {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in
            valueExpectation.fulfill()
        }

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(uploadItem.uploadError, "Upload failed due to unknown reason.")
        subscription.cancel()
    }

    func testCreatesErrorIfTaskCompletesWithReceivingInvalidHttpBody() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let valueExpectation = expectation(description: "received value")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure = completion {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in
            valueExpectation.fulfill()
        }

        testee.urlSession(api.urlSession, dataTask: mockTask, didReceive: Data())
        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testErrorWhenUploadItemMissingFromCoreData() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure(let error) = completion {
                XCTAssertEqual(error, .coreData(.uploadItemNotFound))
            } else {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in }
        databaseClient.delete(uploadItem)
        try? databaseClient.save()

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }

    func testReportsUploadContinuedInAppError() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let subscription = testee.uploadCompleted.sink { completion in
            if case .failure(let error) = completion {
                XCTAssertEqual(error, .uploadContinuedInApp)
            } else {
                XCTFail()
            }
            completionExpectation.fulfill()
        } receiveValue: { _ in }

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: URLError(.backgroundSessionWasDisconnected))

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }
}
