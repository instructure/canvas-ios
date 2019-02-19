//
// Copyright (C) 2016-present Instructure, Inc.
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

class GetDocViewerSessionTest: CoreTestCase {
    class MockTask: URLSessionDataTask {
        override func cancel() {}
        override func resume() {}
    }
    class MockURLSession: URLSession {
        var handler: ((Data?, URLResponse?, Error?) -> Void)?
        override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            handler = completionHandler
            return MockTask()
        }
    }

    func testURLSession() {
        let getSession = GetDocViewerSession(url: URL(string: "/")!, accessToken: "a")
        XCTAssertNotNil(getSession.urlSession.delegate)
    }

    func testExecuteCancelled() {
        let getSession = GetDocViewerSession(url: URL(string: "/")!, accessToken: "a")
        let networkMock = MockURLSession()
        getSession.urlSession = networkMock

        getSession.cancel()
        getSession.execute()
        XCTAssertNil(networkMock.handler)
    }

    func testExecute() {
        let getSession = GetDocViewerSession(url: URL(string: "/")!, accessToken: "a")
        let networkMock = MockURLSession()
        getSession.urlSession = networkMock
        getSession.execute()
        XCTAssertNotNil(networkMock.handler)

        let response = HTTPURLResponse(url: URL(string: "/")!, statusCode: 301, httpVersion: nil, headerFields: [
            "Location": "https://doc.viewer/1/session1/view?query",
        ])
        networkMock.handler?(nil, response, nil)
        XCTAssertEqual(getSession.sessionURL, URL(string: "https://doc.viewer/1/session1"))
    }

    func testRedirect() {
        let getSession = GetDocViewerSession(url: URL(string: "/")!, accessToken: "a")
        let expectation = XCTestExpectation(description: "handler called")
        let url = URL(string: "/")!
        getSession.urlSession(
            getSession.urlSession,
            task: MockTask(),
            willPerformHTTPRedirection: HTTPURLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil),
            newRequest: URLRequest(url: url)
        ) { request in
            XCTAssertNil(request)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }
}
