//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class DefaultMobileVerifyStrategyTests: XCTestCase {

    private let testee = MobileVerify.defaultStrategy
    private let client = APIVerifyClient(
        authorized: true,
        base_url: URL(string: "https://some.domain.com"),
        client_id: "some-id",
        client_secret: "some-secret"
    )

    // MARK: - urlString

    func test_urlString() {
        XCTAssertEqual(testee.urlString, "https://sso.canvaslms.com/api/v1/mobile_verify.json")
    }

    // MARK: - redirectUri

    func test_redirectUri() {
        XCTAssertEqual(testee.redirectUri, "https://sso.canvaslms.com/canvas/login")
    }

    // MARK: - getAuthenticationCode

    func test_getAuthenticationCode_whenUrlMatchesRedirectUri_shouldReturnCode() {
        let url = URL(string: "https://sso.canvaslms.com/canvas/login?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), "some-code")
    }

    func test_getAuthenticationCode_whenHostDiffers_shouldReturnNil() {
        let url = URL(string: "https://some.domain.com/canvas/login?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }

    func test_getAuthenticationCode_whenPathDiffers_shouldReturnNil() {
        let url = URL(string: "https://sso.canvaslms.com/other/path?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }

    func test_getAuthenticationCode_whenCodeParamMissing_shouldReturnNil() {
        let url = URL(string: "https://sso.canvaslms.com/canvas/login?error=access_denied")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }
}

final class UrnIetfMobileVerifyStrategyTests: XCTestCase {

    private let testee = MobileVerify.urnIetfStrategy
    private let client = APIVerifyClient(
        authorized: true,
        base_url: URL(string: "https://some.domain.com"),
        client_id: "some-id",
        client_secret: "some-secret"
    )

    // MARK: - urlString

    func test_urlString() {
        XCTAssertEqual(testee.urlString, "https://sso.canvaslms.com/api/v1/mobile_verify.json")
    }

    // MARK: - redirectUri

    func test_redirectUri() {
        XCTAssertEqual(testee.redirectUri, "urn:ietf:wg:oauth:2.0:oob")
    }

    // MARK: - getAuthenticationCode

    func test_getAuthenticationCode_whenHostMatchesAndPathSuffix_shouldReturnCode() {
        let url = URL(string: "https://some.domain.com/login/oauth2/auth?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), "some-code")
    }

    func test_getAuthenticationCode_whenHostDiffers_shouldReturnNil() {
        let url = URL(string: "https://other.domain.com/login/oauth2/auth?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }

    func test_getAuthenticationCode_whenPathDoesNotMatchSuffix_shouldReturnNil() {
        let url = URL(string: "https://some.domain.com/other/path?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }

    func test_getAuthenticationCode_whenCodeParamMissing_shouldReturnNil() {
        let url = URL(string: "https://some.domain.com/login/oauth2/auth?error=access_denied")!
        XCTAssertEqual(testee.getAuthenticationCode(client: client, url: url), nil)
    }

    func test_getAuthenticationCode_whenClientBaseUrlIsNil_shouldReturnNil() {
        let nilUrlClient = APIVerifyClient(authorized: true, base_url: nil, client_id: "some-id", client_secret: "some-secret")
        let url = URL(string: "https://some.domain.com/login/oauth2/auth?code=some-code")!
        XCTAssertEqual(testee.getAuthenticationCode(client: nilUrlClient, url: url), nil)
    }
}
