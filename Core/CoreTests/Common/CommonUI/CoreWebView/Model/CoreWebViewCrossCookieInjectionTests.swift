//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Combine

class CoreWebViewCrossCookieInjectionTests: XCTestCase {
    private var webViewConfiguration: WKWebViewConfiguration!
    private var webView: WKWebView!
    private var cookieStore: WKHTTPCookieStore!
    private var testee: CoreWebViewCrossCookieInjection!

    override func setUp() {
        super.setUp()
        webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        testee = CoreWebViewCrossCookieInjection()
    }

    func test_injectCrossSiteCookies_createsCrossSiteCookies() {
        // WHEN
        XCTAssertFinish(
            testee.injectCrossSiteCookies(httpCookieStore: cookieStore),
            timeout: 10
        )

        // THEN
        XCTAssertFirstValue(
            cookieStore.getAllCookies(),
            timeout: 10
        ) { cookies in
            XCTAssertEqual(
                cookies.count,
                CoreWebViewCrossCookieInjection.safeDomains.count
            )

            for domain in CoreWebViewCrossCookieInjection.safeDomains {
                guard let crossCookie = cookies.first(where: { $0.domain == ".\(domain)" }) else {
                    XCTFail("No cookie found for domain \(domain)")
                    continue
                }

                let expectedCookie = HTTPCookie.makeCrossSiteCookie(domain: domain)!
                XCTAssertTrue(expectedCookie.isEqualProperties(to: crossCookie))
            }
        }
    }
}
