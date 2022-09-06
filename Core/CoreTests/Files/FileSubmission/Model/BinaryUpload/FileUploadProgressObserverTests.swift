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
    private lazy var mockTask = api.urlSession.dataTask(with: URL(string: "/")!)

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

    // MARK: - Receive API Response

    func testUpdatesFileIDOnSuccessfulBodyResponse() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        uploadItem.uploadError = "testError"
        XCTAssertNil(uploadItem.apiID)
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let apiResponse = try! encoder.encode(APIFile.make(id: "testAPIID"))

        testee.urlSession(api.urlSession, dataTask: mockTask, didReceive: apiResponse)

        XCTAssertEqual(uploadItem.apiID, "testAPIID")
        XCTAssertNil(uploadItem.uploadError)
    }

    // MARK: - Complete With Error

    func testWritesErrorToUploadItem() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: NSError.instructureError("Test Error"))

        XCTAssertEqual(uploadItem.uploadError, "Test Error")
    }

    func testCreatesErrorIfTaskCompletesWithoutErrorAndID() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        XCTAssertEqual(uploadItem.uploadError, "Session completed without error or file ID.")
    }

    // MARK: - Complete Without Error

    func testSignalsCompletionOnUploadFinish() {
        let uploadItem: FileUploadItem = databaseClient.insert()
        let testee = FileUploadProgressObserver(context: databaseClient, fileUploadItemID: uploadItem.objectID)
        let completionExpectation = expectation(description: "completion got signalled")
        let subscription = testee.completion.sink { _ in
            completionExpectation.fulfill()
        } receiveValue: { _ in }

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)

        waitForExpectations(timeout: 0.1)
        subscription.cancel()
    }
}
