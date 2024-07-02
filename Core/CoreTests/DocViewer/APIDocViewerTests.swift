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

class APIDocViewerTests: XCTestCase {
    func testGetDocViewerMetadataRequest() {
        XCTAssertEqual(GetDocViewerMetadataRequest(path: "/1/sessions/{}").path, "/1/sessions/{}")
        XCTAssertEqual(GetDocViewerMetadataRequest(path: "").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil
        ])
    }

    func testGetDocViewerAnnotationsRequest() {
        XCTAssertEqual(GetDocViewerAnnotationsRequest(sessionID: "{}").path, "/2018-04-06/sessions/{}/annotations")
        XCTAssertEqual(GetDocViewerAnnotationsRequest(sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil
        ])
        let date = Date()
        let dateStr = ISO8601DateFormatter.string(from: date, timeZone: TimeZone(identifier: "GMT")!, formatOptions: [.withInternetDateTime, .withFractionalSeconds])
        let data = """
            {"data":[{"id":"1","user_name":"a","page":1,"type":"text","created_at":"\(dateStr)"}]}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try GetDocViewerAnnotationsRequest(sessionID: "{}").decode(data))
        let dateStr2 = ISO8601DateFormatter.string(from: date, timeZone: TimeZone(identifier: "GMT")!, formatOptions: .withInternetDateTime)
        let data2 = """
            {"data":[{"id":"1","user_name":"a","page":1,"type":"text","created_at":"\(dateStr2)"}]}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try GetDocViewerAnnotationsRequest(sessionID: "{}").decode(data2))
    }

    func testPutDocViewerAnnotationRequest() {
        let annotation = APIDocViewerAnnotation.make()
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").method, .put)
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").path, "/2018-03-07/sessions/{}/annotations/1")
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil
        ])
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").body, annotation)
    }

    func testPutDocViewerAnnotationRequestEncode() {
        let annotation = APIDocViewerAnnotation.make()
        XCTAssertNotNil(try PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").encode(annotation))

        let bigContents = String(repeating: "a", count: PutDocViewerAnnotationRequest.SizeLimit)
        let big = APIDocViewerAnnotation.make(contents: bigContents)
        XCTAssertThrowsError(try PutDocViewerAnnotationRequest(body: big, sessionID: "{}").encode(big))
    }

    func testPutDocViewerAnnotationRequestDecode() {
        let annotation = APIDocViewerAnnotation.make()

        let date = Date()
        let dateStr = ISO8601DateFormatter.string(from: date, timeZone: TimeZone(identifier: "GMT")!, formatOptions: [.withInternetDateTime, .withFractionalSeconds])
        let data = """
            {"id":"1","user_name":"a","page":1,"type":"text","created_at":"\(dateStr)"}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").decode(data))
        let dateStr2 = ISO8601DateFormatter.string(from: date, timeZone: TimeZone(identifier: "GMT")!, formatOptions: .withInternetDateTime)
        let data2 = """
            {"id":"1","user_name":"a","page":1,"type":"text","created_at":"\(dateStr2)"}
        """.data(using: .utf8)!
        XCTAssertNoThrow(try PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").decode(data2))
    }

    func testDeleteDocViewerAnnotationRequest() {
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").method, .delete)
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").path, "/1/sessions/{}/annotations/1")
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil
        ])
    }

    func testCanvaDocSessionRequest() {
        XCTAssertEqual(CanvaDocsSessionRequest.DraftAttempt, "draft")

        let testee = CanvaDocsSessionRequest(submissionId: "1", attempt: "2")
        XCTAssertEqual(testee.body, CanvaDocsSessionRequest.RequestBody(submission_attempt: "2", submission_id: "1"))
        XCTAssertEqual(testee.method, .post)
        XCTAssertEqual(testee.path, "canvadoc_session")

        let defaultParamTestee = CanvaDocsSessionRequest(submissionId: "3")
        XCTAssertEqual(defaultParamTestee.body, CanvaDocsSessionRequest.RequestBody(submission_attempt: "draft", submission_id: "3"))
    }
}
