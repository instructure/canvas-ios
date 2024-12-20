//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class CoreWebViewContentErrorViewModelTests: XCTestCase {

    func testSubtitleWhenURLAvailable() {
        let testee = CoreWebViewContentErrorViewModel(urlToOpenInBrowser: .make())
        XCTAssertEqual(testee.subtitle,
                       "Something went wrong beyond our control.\nYou can try to open the page in a browser.")
    }

    func testSubtitleWhenURLNotAvailable() {
        let testee = CoreWebViewContentErrorViewModel(urlToOpenInBrowser: nil)
        XCTAssertEqual(testee.subtitle,
                       "Something went wrong beyond our control.")
    }

    func testOpenInBrowserButtonDisplayWhenURLAvailable() {
        let testee = CoreWebViewContentErrorViewModel(urlToOpenInBrowser: .make())
        XCTAssertTrue(testee.shouldDisplayOpenInBrowserButton)
    }

    func testOpenInBrowserButtonDisplayWhenURLNotAvailable() {
        let testee = CoreWebViewContentErrorViewModel(urlToOpenInBrowser: nil)
        XCTAssertFalse(testee.shouldDisplayOpenInBrowserButton)
    }

    func testOpensAuthenticatedURLWhenOpenInBrowserButtonTapped() {
        let authenticationAPIInvoked = expectation(description: "")
        let url = URL(string: "https://test")!
        API.resetMocks()
        AppEnvironment.shared.api.mock(GetWebSessionRequest(to: url)) { _ in
            authenticationAPIInvoked.fulfill()
            return (nil, nil, nil)
        }
        let testee = CoreWebViewContentErrorViewModel(urlToOpenInBrowser: url)

        // WHEN
        testee.openInBrowserButtonTapped()

        // THEN
        waitForExpectations(timeout: 1)
    }
}
