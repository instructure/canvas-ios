//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
@testable import Parent
import XCTest
import WebKit
import TestsFoundation

class ParentSubmissionInteractorTests: ParentTestCase {

    func testLoadsParentSubmissionWebsite() {
        let parentID = "parentID"
        let studentID = "studentID"
        let host = "testHost"
        let loginSession = LoginSession(
            baseURL: URL(string: "https://\(host)/api/v1")!,
            userID: parentID,
            userName: "Test Parent"
        )
        let assignmentURL = URL(string: "https://\(host)/assignment/123/submissions")!
        let authenticatedSessionURL = URL(string: "https://authenticated")!
        let sessionRequested = expectation(description: "sessionRequested")
        api.mock(GetWebSessionRequest(to: assignmentURL)) { _ in
            sessionRequested.fulfill()
            let response = GetWebSessionRequest.Response(
                session_url: authenticatedSessionURL,
                requires_terms_acceptance: false
            )
            return (response, nil, nil)
        }

        let mockWebView = MockWebView()

        let testee = ParentSubmissionInteractorLive(
            assignmentHtmlURL: assignmentURL,
            observedUserID: studentID,
            loginSession: loginSession,
            api: api
        )
        let expectedCookie = HTTPCookie(
            properties: [
                .name: "k5_observed_user_for_\(parentID)",
                .value: studentID,
                .domain: host,
                .path: "/",
                .version: 1
            ]
        )!

        // WHEN
        XCTAssertFinish(testee.loadParentFeedbackView(webView: mockWebView), timeout: 10)

        // THEN
        wait(for: [sessionRequested], timeout: 1)
        XCTAssertFirstValue(
            mockWebView.configuration.websiteDataStore.httpCookieStore.getAllCookies(),
            timeout: 10,
            assertions: { cookies in
                XCTAssertTrue(expectedCookie.isEqualProperties(to: cookies.first))
            }
        )
        XCTAssertEqual(mockWebView.receivedRequestToLoad, URLRequest(url: authenticatedSessionURL))
        XCTAssertEqual(mockWebView.isLoadingChecked, true)
    }
}

private class MockWebView: WKWebView {
    private(set) var receivedRequestToLoad: URLRequest?
    private(set) var isLoadingChecked = false

    init() {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        super.init(frame: .zero, configuration: config)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isLoading: Bool {
        isLoadingChecked = true
        return false
    }

    override func load(_ request: URLRequest) -> WKNavigation? {
        receivedRequestToLoad = request
        return nil
    }
}
