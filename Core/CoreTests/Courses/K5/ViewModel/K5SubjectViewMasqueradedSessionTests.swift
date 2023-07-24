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

import XCTest
@testable import Core
import WebKit

class K5SubjectViewMasqueradedSessionTests: CoreTestCase {

    func testMasqueradedUserUsesNonSharedCookieStorage() {
        let testee = K5SubjectViewMasqueradedSession(env: environment)
        XCTAssertEqual(testee.config.websiteDataStore.httpCookieStore, WKWebsiteDataStore.default().httpCookieStore)

        setupMasqueradedSession()
        XCTAssertNotNil(testee.config)
        XCTAssertNotEqual(testee.config.websiteDataStore.httpCookieStore, WKWebsiteDataStore.default().httpCookieStore)
    }

    func testHandlesTabChangeEvents() {
        let testee = K5SubjectViewMasqueradedSession(env: environment)
        XCTAssertFalse(testee.handlesTabChangeEvents)

        setupMasqueradedSession()
        XCTAssertTrue(testee.handlesTabChangeEvents)
    }

    func testFetchesSessionURL() {
        let sessionExpectation = expectation(description: "Session fetched from API")
        let request = GetWebSessionRequest(to: URL(string: "/first_tab_url")!, path: "login/session_token")
        api.mock(request, value: .init(session_url: URL(string: "/session_url")!, requires_terms_acceptance: false))

        let testee = K5SubjectViewMasqueradedSession(env: environment)
        let subscription = testee.sessionURL.sink { url in
            sessionExpectation.fulfill()
            XCTAssertEqual(url, URL(string: "/session_url"))
        }
        testee.tabChanged(toIndex: 1, toURL: URL(string: "/first_tab_url")!)

        wait(for: [sessionExpectation], timeout: 0.1)
        subscription.cancel()
    }

    private func setupMasqueradedSession() {
        let mockURL = URL(string: "/path")!
        let masqueradedSession = LoginSession(baseURL: mockURL, masquerader: mockURL, userID: "1", userName: "masqueraded")
        environment.currentSession = masqueradedSession
    }
}
