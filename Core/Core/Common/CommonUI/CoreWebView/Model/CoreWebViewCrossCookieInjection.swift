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

import Combine
import WebKit

/// The "Allow Cross-Website Tracking" switch only works for trusted domains.
/// A way to make a domain trusted is to inject a cookie for it before it's being loaded within an iframe.
class CoreWebViewCrossCookieInjection {
    static let safeDomains = [
        "canvas-user-content.com"
    ]

    func injectCrossSiteCookies(
        httpCookieStore: WKHTTPCookieStore
    ) -> AnyPublisher<Void, Never> {
        let crossCookies = Self.safeDomains.compactMap { domain in
            HTTPCookie.makeCrossSiteCookie(domain: domain)
        }
        return httpCookieStore
            .setCookies(crossCookies)
            .eraseToAnyPublisher()
    }
}

extension HTTPCookie {

    static func makeCrossSiteCookie(domain: String) -> HTTPCookie? {
        var cookieProperties: [HTTPCookiePropertyKey: Any] = [:]
        cookieProperties[.name] = "canvas_ios_trusted_domain"
        cookieProperties[.value] = "true"
        cookieProperties[.domain] = ".\(domain)"
        cookieProperties[.path] = "/"
        cookieProperties[.sameSitePolicy] = "None"
        cookieProperties[.version] = "1"
        return HTTPCookie(properties: cookieProperties)
    }
}
