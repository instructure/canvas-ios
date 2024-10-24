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
import CoreData
import TestsFoundation
import XCTest

class BackgroundURLSessionProviderTests: CoreTestCase {
    private var testee: BackgroundURLSessionProvider!
    private var mockUploadProgressObserversCache: MockFileUploadProgressObserversCache!

    override func setUp() {
        super.setUp()
        mockUploadProgressObserversCache = MockFileUploadProgressObserversCache()
        testee = BackgroundURLSessionProvider(sessionID: "testSession", sharedContainerID: "testContainer", uploadProgressObserversCache: mockUploadProgressObserversCache)
    }

    override func tearDown() {
        testee = nil
        mockUploadProgressObserversCache = nil
        super.tearDown()
    }

    // MARK: - URLSession Lifecycle Tests

    func testURLSessionProperties() {
        let session = testee.session
        XCTAssertEqual(session.configuration.sharedContainerIdentifier, "testContainer")
        XCTAssertEqual(session.configuration.identifier, "testSession")
    }

    func testCachesURLSession() {
        let session1 = testee.session
        let session2 = testee.session
        XCTAssertEqual(session1, session2)
    }

    func testCreatesNewSessionIfSessionBecameInvalid() {
        testee = BackgroundURLSessionProvider(
            sessionID: "testSession",
            sharedContainerID: "testContainer",
            sessionConfigurationProtocolClasses: [URLProtocolMock.self],
            uploadProgressObserversCache: mockUploadProgressObserversCache
        )

        let oldSession = testee.session
        oldSession.invalidateAndCancel()
        RunLoop.main.run(until: Date() + 1)
        XCTAssertNotEqual(oldSession, testee.session)
    }

    // MARK: - Event Forwarding To Upload Observer Tests

    func testForwardsURLSessionEventsToProgressObserver() {
        XCTAssertNil(mockUploadProgressObserversCache.receivedProgressUpdate)
        XCTAssertNil(mockUploadProgressObserversCache.receivedCompletionError)
        XCTAssertNil(mockUploadProgressObserversCache.receivedData)
        let mockTask = api.urlSession.dataTask(with: .make())

        testee.urlSession(api.urlSession, task: mockTask, didSendBodyData: 1, totalBytesSent: 2, totalBytesExpectedToSend: 3)

        let progressResult = mockUploadProgressObserversCache.receivedProgressUpdate
        XCTAssertEqual(progressResult?.bytesSent, 1)
        XCTAssertEqual(progressResult?.totalBytesSent, 2)
        XCTAssertEqual(progressResult?.totalBytesExpectedToSend, 3)

        testee.urlSession(api.urlSession, dataTask: mockTask, didReceive: "test".data(using: .utf8)!)
        XCTAssertEqual(mockUploadProgressObserversCache.receivedData, "test".data(using: .utf8)!)

        testee.urlSession(api.urlSession, task: mockTask, didCompleteWithError: NSError.instructureError("test error"))
        XCTAssertEqual(mockUploadProgressObserversCache.receivedCompletionError?.localizedDescription, NSError.instructureError("test error").localizedDescription)
    }
}

final class MockFileUploadProgressObserversCache: FileUploadProgressObserversCache {
    public nonisolated(unsafe) var receivedProgressUpdate: (bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)?
    public nonisolated(unsafe) var receivedCompletionError: Error?
    public nonisolated(unsafe) var receivedData: Data?

    init() {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        super.init(context: context, factory: { _, _ in
            FileUploadProgressObserver(context: context, fileUploadItemID: NSManagedObjectID())
        })
    }

    public override func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        receivedProgressUpdate = (bytesSent, totalBytesSent, totalBytesExpectedToSend)
    }

    public override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        receivedCompletionError = error
    }

    public override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData = data
    }
}

private class URLProtocolMock: URLProtocol {
    override class func canInit(with _: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {}

    override func stopLoading() {}
}
