//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import XCTest
@testable import Core
import TestsFoundation

class DocViewerSessionTests: CoreTestCase {
    func testCancel() {
        let session = DocViewerSession {}
        let task = MockAPITask(api, request: URLRequest(url: URL(string: "/")!))
        session.task = task
        session.cancel()
        XCTAssertEqual(task.state, .canceling)
    }

    func testLoad() {
        let session = DocViewerSession {}
        let url = URL(string: "/")!
        let response = HTTPURLResponse(url: URL(string: "/")!, statusCode: 301, httpVersion: nil, headerFields: [
            "Location": "https://doc.viewer/1/session1/view?query"
        ])
        let loginSession = LoginSession.make()
        api.mock(url: url, response: response)
        session.load(url: url, session: loginSession)
        XCTAssertEqual(session.sessionURL, URL(string: "https://doc.viewer/1/session1"))
    }

    func testLoadFailure() {
        let session = DocViewerSession {}
        let url = URL(string: "/")!
        let loginSession = LoginSession.make()
        api.mock(url: url, error: APIDocViewerError.noData)
        session.load(url: URL(string: "/")!, session: loginSession)
        XCTAssertNotNil(session.error)
        XCTAssertNil(session.sessionURL)
    }

    func testLoadMetadata() {
        let notified = expectation(description: "notified")
        let sessionURL = URL(string: "https://doc.viewer/1/session1")!
        let metadata = APIDocViewerMetadata.make()
        let session = DocViewerSession { notified.fulfill() }
        api.mock(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: nil, response: HTTPURLResponse(url: sessionURL, statusCode: 202, httpVersion: nil, headerFields: nil))
        session.loadMetadata(sessionURL: sessionURL)

        api.mock(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: metadata)
        wait(for: [notified], timeout: 4)

        XCTAssertNil(session.error)
        XCTAssertEqual(session.metadata, metadata)
        XCTAssertEqual(session.remoteURL, URL(string: "download", relativeTo: sessionURL))
    }

    func testLoadMetadataFailure() {
        let notified = expectation(description: "notified")
        let sessionURL = URL(string: "https://doc.viewer/1/session1")!
        let session = DocViewerSession { notified.fulfill() }
        api.mock(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: nil, error: APIDocViewerError.noData)
        session.loadMetadata(sessionURL: sessionURL)
        wait(for: [notified], timeout: 1)
        XCTAssertNotNil(session.error)
        XCTAssertNil(session.metadata)
        XCTAssertNil(session.remoteURL)
    }

    func testLoadAnnotationsAndOrderByCreationDate() {
        let session = DocViewerSession { XCTFail("Must not notify") }
        session.metadata = .make()
        api.mock(GetDocViewerAnnotationsRequest(sessionID: ""), value: APIDocViewerAnnotations(data: [
            .make(id: "1", created_at: Date(timeIntervalSince1970: 1)),
            .make(id: "2", created_at: Date(timeIntervalSince1970: 0))
        ]))
        session.loadAnnotations()
        XCTAssertEqual(session.annotations?.count, 2)
        XCTAssertEqual(session.annotations?[0], .make(id: "2", created_at: Date(timeIntervalSince1970: 0)))
        XCTAssertEqual(session.annotations?[1], .make(id: "1", created_at: Date(timeIntervalSince1970: 1)))
    }

    func testLoadAnnotationsAfterDoc() {
        let notified = expectation(description: "notified")
        let session = DocViewerSession { notified.fulfill() }
        session.metadata = .make()
        session.localURL = URL(string: "download")
        session.loadAnnotations()
        wait(for: [notified], timeout: 1)
        XCTAssertEqual(session.annotations?.count, 0)
    }

    func testLoadAnnotationsAfterError() {
        let notified = expectation(description: "notified")
        let session = DocViewerSession { notified.fulfill() }
        session.metadata = .make()
        session.error = APIDocViewerError.noData
        session.loadAnnotations()
        wait(for: [notified], timeout: 1)
        XCTAssertEqual(session.annotations?.count, 0)
    }

    func testLoadAnnotationsWithoutMeta() {
        let session = DocViewerSession {}
        session.loadAnnotations()
        XCTAssertEqual(session.annotations?.count, 0)
    }

    func testLoadDocument() {
        let downloadURL = URL(string: "download")!
        let tempURL = Bundle(for: DocViewerSessionTests.self).url(forResource: "instructure", withExtension: "pdf")!
        let notified = expectation(description: "notified")
        let session = DocViewerSession { notified.fulfill() }
        session.annotations = []
        api.mockDownload(downloadURL, value: tempURL)
        session.loadDocument(downloadURL: downloadURL)
        XCTAssertEqual(session.remoteURL, downloadURL)
        wait(for: [notified], timeout: 1)
        XCTAssertNotNil(session.localURL)
    }

    func testLoadDocumentFailure() {
        let downloadURL = URL(string: "download")!
        let session = DocViewerSession { XCTFail("Must not notify without annotations set") }
        api.mockDownload(downloadURL, error: APIDocViewerError.noData)
        session.loadDocument(downloadURL: downloadURL)
        XCTAssertEqual(session.remoteURL, downloadURL)
        XCTAssertNotNil(session.error)
    }
}
