//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

class APIQueryItemTests: XCTestCase {
    func testToQueryItems() {
        XCTAssertEqual(APIQueryItem.name("param").toURLQueryItems(), [URLQueryItem(name: "param", value: nil)])
        XCTAssertEqual(APIQueryItem.value("a", "b").toURLQueryItems(), [URLQueryItem(name: "a", value: "b")])
        XCTAssertEqual(APIQueryItem.array("include", [ "a", "b" ]).toURLQueryItems(), [URLQueryItem(name: "include[]", value: "a"), URLQueryItem(name: "include[]", value: "b")])
        XCTAssertEqual(APIQueryItem.include([ "a", "b" ]).toURLQueryItems(), [URLQueryItem(name: "include[]", value: "a"), URLQueryItem(name: "include[]", value: "b")])
        XCTAssertEqual(APIQueryItem.perPage(10).toURLQueryItems(), [URLQueryItem(name: "per_page", value: "10")])
        XCTAssertEqual(APIQueryItem.bool("do_it", true).toURLQueryItems(), [URLQueryItem(name: "do_it", value: "1")])
        XCTAssertEqual(APIQueryItem.bool("do_it", false).toURLQueryItems(), [URLQueryItem(name: "do_it", value: "0")])
        XCTAssertEqual(APIQueryItem.optionalBool("do_it", false).toURLQueryItems(), [URLQueryItem(name: "do_it", value: "0")])
        XCTAssertEqual(APIQueryItem.optionalBool("do_it", nil).toURLQueryItems(), [])
    }

    func testToPercentEncodedQueryItems() {
        XCTAssertEqual(
            APIQueryItem.name("param").toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "param", value: nil)]
        )
        XCTAssertEqual(
            APIQueryItem.value("a", "b").toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "a", value: "b")]
        )
        XCTAssertEqual(
            APIQueryItem.array("include", [ "a", "b" ]).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "include%5B%5D", value: "a"), URLQueryItem(name: "include%5B%5D", value: "b")]
        )
        XCTAssertEqual(
            APIQueryItem.include([ "a", "b" ]).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "include%5B%5D", value: "a"), URLQueryItem(name: "include%5B%5D", value: "b")]
        )
        XCTAssertEqual(
            APIQueryItem.optionalValue("date", "2024-01-01T12:00:00+01:00").toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "date", value: "2024-01-01T12%3A00%3A00%2B01%3A00")]
        )
        XCTAssertEqual(
            APIQueryItem.perPage(10).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "per_page", value: "10")]
        )
        XCTAssertEqual(
            APIQueryItem.bool("do_it", true).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "do_it", value: "1")]
        )
        XCTAssertEqual(
            APIQueryItem.bool("do_it", false).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "do_it", value: "0")]
        )
        XCTAssertEqual(
            APIQueryItem.optionalBool("do_it", false).toPercentEncodedURLQueryItems(),
            [URLQueryItem(name: "do_it", value: "0")]
        )
        XCTAssertEqual(
            APIQueryItem.optionalBool("do_it", nil).toPercentEncodedURLQueryItems(),
            []
        )
    }
}

class APIRequestableTests: XCTestCase {
    let baseURL = URL(string: "https://cgnuonline-eniversity.edu")!
    let accessToken = "fhwdgads"

    struct DateHaver: Codable, Equatable {
        var date = Date(timeIntervalSince1970: 0)
    }

    struct GetDate: APIRequestable {
        typealias Response = DateHaver
        let path = "date"
    }

    struct InvalidPath: APIRequestable {
        typealias Response = DateHaver
        let path = "<>"
    }

    struct GetQueryItems: APIRequestable {
        typealias Response = DateHaver
        let path = ""
        let query: [APIQueryItem] = [.name("query")]
    }

    struct GetEmptyQueryItems: APIRequestable {
        typealias Response = DateHaver
        let path = "data"
        let query: [APIQueryItem] = []
    }

    struct GetPercentEncodedQueryItems: APIRequestable {
        typealias Response = DateHaver
        var useExtendedPercentEncoding = true
        let path = "calendar"
        let query: [APIQueryItem] = [.value("startDate", "2024-01-01T10:39:00.000+00:00")]
    }

    struct PostBody: APIRequestable {
        typealias Response = DateHaver
        typealias Body = DateHaver
        let body: Body? = DateHaver()
        let method: APIMethod = .post
        let path = "post"
    }

    class PostForm: APIRequestable {
        typealias Response = DateHaver
        var isBodyFromURL: Bool { false }
        let path = "form"
        let form: APIFormData? = [
            (key: "string", value: .string("abcde")),
            (key: "data", value: .data(filename: "data.txt", type: "text/plain", data: "hi".data(using: .utf8)!)),
            (key: "file", value: .file(filename: "file.gif", type: "image/gif", at: URL(string: "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==")!))
        ]
    }

    class PostFormWithExternalBody: PostForm {
        override var isBodyFromURL: Bool { true }
    }

    struct UploadBody: APIRequestable {
        typealias Response = DateHaver
        let body: String?
        let method: APIMethod = .post
        let path = "upload"
        func encode(_ body: String) throws -> Data {
            return body.data(using: .utf8)!
        }
    }

    struct CrossDomain: APIRequestable {
        typealias Response = DateHaver
        var path: String {
            return "https://s3.instructure.com/bucket/1"
        }
    }

    func expectedUrlRequest(path: String) -> URLRequest {
        var expected = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        expected.httpMethod = "GET"
        expected.setValue("application/json+canvas-string-ids", forHTTPHeaderField: HttpHeader.accept)
        expected.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeader.authorization)
        expected.setValue(UserAgent.default.description, forHTTPHeaderField: HttpHeader.userAgent)
        return expected
    }

    func testAPIUserAgent() {
        XCTAssert(UserAgent.default.description.contains(UIDevice.current.model))
        XCTAssert(UserAgent.default.description.contains(UIDevice.current.systemName))
        XCTAssert(UserAgent.default.description.contains(UIDevice.current.systemVersion))
    }

    func testUrlRequestPath() {
        let expected = expectedUrlRequest(path: "api/v1/date?no_verifiers=1")
        XCTAssertEqual(try GetDate().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil), expected)
    }

    func testUrlRequestInvalidPath() {
        XCTAssertNoThrow(try InvalidPath().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil))
    }

    func testUrlRequestQuery() {
        let expected = expectedUrlRequest(path: "api/v1/?query&no_verifiers=1")
        XCTAssertEqual(try GetQueryItems().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil), expected)
    }

    func testActAsUserIDWithRegularQueryItems() {
        let expected = expectedUrlRequest(path: "api/v1/?query&as_user_id=78&no_verifiers=1")
        XCTAssertEqual(try GetQueryItems().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: "78"), expected)
    }

    func testActAsUserIDWithEmptyQueryItems() {
        let expected = expectedUrlRequest(path: "api/v1/data?as_user_id=78&no_verifiers=1")
        XCTAssertEqual(try GetEmptyQueryItems().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: "78"), expected)
    }

    func testActAsUserIDWithPercentEncodedQueryItems() {
        let expected = expectedUrlRequest(path: "api/v1/calendar?startDate=2024-01-01T10%3A39%3A00.000%2B00%3A00&as_user_id=78&no_verifiers=1")
        XCTAssertEqual(try GetPercentEncodedQueryItems().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: "78"), expected)
    }

    func testUrlRequest() {
        var expected = expectedUrlRequest(path: "api/v1/post?no_verifiers=1")
        expected.httpMethod = "POST"
        expected.setValue("application/json", forHTTPHeaderField: "Content-Type")
        expected.httpBody = "{\"date\":\"1970-01-01T00:00:00Z\"}".data(using: .utf8)
        XCTAssertEqual(try PostBody().urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil), expected)
    }

    func testUrlRequestNoToken() {
        var expected = expectedUrlRequest(path: "api/v1/post?no_verifiers=1")
        expected.httpMethod = "POST"
        expected.setValue("application/json", forHTTPHeaderField: "Content-Type")
        expected.setValue(nil, forHTTPHeaderField: HttpHeader.authorization)
        expected.httpBody = "{\"date\":\"1970-01-01T00:00:00Z\"}".data(using: .utf8)
        XCTAssertEqual(try PostBody().urlRequest(relativeTo: baseURL, accessToken: nil, actAsUserID: nil), expected)
    }

    func testUrlRequestIgnoresNoVerifierParameterForExcludedRequest() throws {
        let noVerifierRequest = LoginWebRequest(authMethod: .siteAdminLogin, clientID: "", provider: "")

        let request = try noVerifierRequest.urlRequest(relativeTo: baseURL, accessToken: "token", actAsUserID: "123")

        XCTAssertEqual(request.url?.query(percentEncoded: true)?.contains("as_user_id=123"), true)
        XCTAssertEqual(request.url?.query(percentEncoded: true)?.contains("no_verifier"), false)
    }

    func testGetNext() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1"
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        XCTAssertEqual(GetDate().getNext(from: response)?.path, next)
        XCTAssertEqual(GetNextRequest<DateHaver>(path: next).path, next)
    }

    func testGetNextNone() {
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\""
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        XCTAssertNil(GetDate().getNext(from: response))
        let response2 = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
        XCTAssertNil(GetDate().getNext(from: response2))
    }

    func testHttpBody() throws {
        let requestable = UploadBody(body: "hello")
        let expected = try requestable.encode("hello")
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        XCTAssertEqual(request.httpBody, expected)
    }

    func testFormData() throws {
        UUID.mock("xxzzxx")
        let requestable = PostForm()
        let expected: Data = try requestable.form!.encode(using: UUID.string)
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        XCTAssertEqual(request.httpBody, expected)
        XCTAssertEqual(request.allHTTPHeaderFields?[HttpHeader.contentType], "multipart/form-data; charset=utf-8; boundary=\"xxzzxx\"")
    }

    func testFormDataWithSkippedHttpBody() throws {
        UUID.mock("xxzzxx")
        let requestable = PostFormWithExternalBody()
        let request = try requestable.urlRequest(relativeTo: baseURL, accessToken: accessToken, actAsUserID: nil)
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.allHTTPHeaderFields?[HttpHeader.contentType], "multipart/form-data; charset=utf-8; boundary=\"xxzzxx\"")
    }

    func testAuthorizationHeaderSameDomain() throws {
        let urlRequest = URLRequest(url: baseURL.appendingPathComponent("api/v1/courses"))
        var request = try urlRequest.urlRequest(relativeTo: baseURL, accessToken: "token", actAsUserID: nil)
        XCTAssertEqual(request.allHTTPHeaderFields?[HttpHeader.authorization], "Bearer token")

        let requestable = CrossDomain()
        let url = URL(string: requestable.path)!
        request = try requestable.urlRequest(relativeTo: url, accessToken: "token", actAsUserID: nil)
        XCTAssertEqual(request.allHTTPHeaderFields?[HttpHeader.authorization], "Bearer token")
    }

    func testAuthorizationOtherDomain() throws {
        let requestable = CrossDomain()
        var request = try requestable.urlRequest(relativeTo: baseURL, accessToken: "token", actAsUserID: nil)
        XCTAssertNil(request.allHTTPHeaderFields?[HttpHeader.authorization])

        let urlRequest = URLRequest(url: URL(string: "https://s3.amazon.com")!)
        request = try urlRequest.urlRequest(relativeTo: baseURL, accessToken: "token", actAsUserID: nil)
        XCTAssertNil(request.allHTTPHeaderFields?[HttpHeader.authorization])
    }
}
