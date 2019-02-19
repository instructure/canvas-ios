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

import XCTest
@testable import Core

class APIDocViewerRequestableTests: XCTestCase {
    func testGetDocViewerMetadataRequest() {
        XCTAssertEqual(GetDocViewerMetadataRequest(path: "/1/sessions/{}").path, "/1/sessions/{}")
        XCTAssertEqual(GetDocViewerMetadataRequest(path: "").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil,
        ])
    }

    func testGetDocViewerAnnotationsRequest() {
        XCTAssertEqual(GetDocViewerAnnotationsRequest(sessionID: "{}").path, "/2018-04-06/sessions/{}/annotations")
        XCTAssertEqual(GetDocViewerAnnotationsRequest(sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil,
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
        XCTAssertThrowsError(try GetDocViewerAnnotationsRequest(sessionID: "{}").decode(data2))
    }

    func testPutDocViewerAnnotationRequest() {
        let annotation = APIDocViewerAnnotation(
            id: "1", document_id: nil, user_id: nil, user_name: "a", page: 1, created_at: nil, modified_at: nil,
            deleted: false, deleted_at: nil, deleted_by: nil, deleted_by_id: nil, type: .text, color: nil, icon: nil,
            contents: nil, inreplyto: nil, coords: nil, rect: [[0, 0], [1, 1]], font: nil, inklist: nil, width: nil
        )
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").method, .put)
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").path, "/2018-03-07/sessions/{}/annotations/1")
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil,
        ])
        XCTAssertEqual(PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").body, annotation)
    }

    func testPutDocViewerAnnotationRequestEncode() {
        let annotation = APIDocViewerAnnotation(
            id: "1", document_id: nil, user_id: nil, user_name: "a", page: 1, created_at: nil, modified_at: nil,
            deleted: false, deleted_at: nil, deleted_by: nil, deleted_by_id: nil, type: .text, color: nil, icon: nil,
            contents: nil, inreplyto: nil, coords: nil, rect: [[0, 0], [1, 1]], font: nil, inklist: nil, width: nil
        )
        XCTAssertNotNil(try PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").encode(annotation))

        let bigContents = String(repeating: "a", count: PutDocViewerAnnotationRequest.SizeLimit)
        let big = APIDocViewerAnnotation(
            id: "1", document_id: nil, user_id: nil, user_name: "a", page: 1, created_at: nil, modified_at: nil,
            deleted: false, deleted_at: nil, deleted_by: nil, deleted_by_id: nil, type: .text, color: nil, icon: nil,
            contents: bigContents, inreplyto: nil, coords: nil, rect: [[0, 0], [1, 1]], font: nil, inklist: nil, width: nil
        )
        XCTAssertThrowsError(try PutDocViewerAnnotationRequest(body: big, sessionID: "{}").encode(big))
    }

    func testPutDocViewerAnnotationRequestDecode() {
        let annotation = APIDocViewerAnnotation(
            id: "1", document_id: nil, user_id: nil, user_name: "a", page: 1, created_at: nil, modified_at: nil,
            deleted: false, deleted_at: nil, deleted_by: nil, deleted_by_id: nil, type: .text, color: nil, icon: nil,
            contents: nil, inreplyto: nil, coords: nil, rect: [[0, 0], [1, 1]], font: nil, inklist: nil, width: nil
        )

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
        XCTAssertThrowsError(try PutDocViewerAnnotationRequest(body: annotation, sessionID: "{}").decode(data2))
    }

    func testDeleteDocViewerAnnotationRequest() {
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").method, .delete)
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").path, "/1/sessions/{}/annotations/1")
        XCTAssertEqual(DeleteDocViewerAnnotationRequest(annotationID: "1", sessionID: "{}").headers, [
            HttpHeader.accept: "application/json",
            HttpHeader.authorization: nil,
        ])
    }
}
