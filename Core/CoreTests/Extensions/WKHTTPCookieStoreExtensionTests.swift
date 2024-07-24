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
import WebKit
import XCTest

class WKHTTPCookieStoreExtensionTests: XCTestCase {

    func testGetAllCookies() {
        let webView = WKWebView(frame: .zero)
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let cookie = HTTPCookie(
            properties: [
                .name: "testName",
                .value: "testValue",
                .path: "/login",
                .domain: "instructure.com",
                .version: 1
            ]
        )!
        let cookieWasSet = expectation(description: "Cookie was set.")
        cookieStore.setCookie(cookie) {
            cookieWasSet.fulfill()
        }
        wait(for: [cookieWasSet], timeout: 10)

        // WHEN
        let publisher = cookieStore.getAllCookies()

        // THEN
        XCTAssertSingleOutputEquals(
            publisher,
            [cookie],
            timeout: 10
        )
    }
}
