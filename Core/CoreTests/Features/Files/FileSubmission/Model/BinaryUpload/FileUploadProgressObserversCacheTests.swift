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

@testable import Core
import XCTest

class FileUploadProgressObserversCacheTests: CoreTestCase {

    func testInvokesFactoryOnNewURLSessionTaskCallback() {
        // MARK: - GIVEN
        let factoryExpectation = expectation(description: "Factory method only called once")
        var mockObserver: MockFileUploadProgressObserver?
        let testee = FileUploadProgressObserversCache(context: databaseClient) { _, fileUploadItemID in
            factoryExpectation.fulfill()
            let observer = MockFileUploadProgressObserver(context: self.databaseClient, fileUploadItemID: fileUploadItemID)
            mockObserver = observer
            return observer
        }
        let submission = databaseClient.insert() as FileSubmission
        let item = databaseClient.insert() as FileUploadItem
        item.fileSubmission = submission
        let mockTask = api.urlSession.dataTask(with: .make())
        mockTask.taskID = item.objectID.uriRepresentation().absoluteString

        // MARK: - WHEN
        testee.urlSession(api.urlSession, task: mockTask, didSendBodyData: 1, totalBytesSent: 1, totalBytesExpectedToSend: 1)
        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: nil)
        testee.urlSession(api.urlSession, dataTask: mockTask, didReceive: Data())

        // MARK: - THEN
        waitForExpectations(timeout: 0.1)
        guard let mockObserver = mockObserver else { return }

        XCTAssertTrue(mockObserver.didReceiveProgressCallback)
        XCTAssertTrue(mockObserver.didReceiveDataCallback)
        XCTAssertTrue(mockObserver.didReceiveCompletionCallback)
    }
}

final class MockFileUploadProgressObserver: FileUploadProgressObserver {
    nonisolated(unsafe) var didReceiveProgressCallback = false
    nonisolated(unsafe) var didReceiveCompletionCallback = false
    nonisolated(unsafe) var didReceiveDataCallback = false

    public override func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        didReceiveProgressCallback = true
    }

    public override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        didReceiveCompletionCallback = true
    }

    public override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        didReceiveDataCallback = true
    }
}
