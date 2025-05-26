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
@testable import Core
import XCTest

class AccessTokenRefreshInteractorTests: CoreTestCase {
    var testee: AccessTokenRefreshInteractor!

    override func setUp() {
        super.setUp()
        testee = AccessTokenRefreshInteractor()
    }

    // MARK: - Success Scenario

    func test_pkceOAuth_refreshToken_refreshSucceeds() {
        let loginSession = LoginSession.mockPKCEOAuth()
        api.loginSession = loginSession
        guard let oauthType = loginSession.oauthType else {
            return XCTFail("OAuth type not set for login session")
        }
        let pkceOauth = OAuthType.pkce(
            .init(
                baseURL: api.baseURL,
                clientID: oauthType.clientID,
                codeVerifier: oauthType.codeVerifier
            )
        )
        let request = PostLoginOAuthRequest(
            oauthType: pkceOauth,
            refreshToken: loginSession.refreshToken!
        )
        let response = APIOAuthToken(
            access_token: "new_access_token",
            refresh_token: "new_refresh_token",
            token_type: "new_token_type",
            user: .make(
                id: "new_id",
                name: "new_name",
                effectiveLocale: "new_locale",
                email: "new_email"
            ),
            real_user: .init(id: "new_real_id", name: "new_real_name"),
            expires_in: 0,
            canvas_region: "us-east-1"
        )
        api.mock(request, value: response)
        let expectedToken = loginSession.refresh(
            accessToken: response.access_token,
            expiresAt: Clock.now + response.expires_in!
        )

        // WHEN
        let publisher = testee.refreshAccessToken(api: api)

        // THEN
        XCTAssertSingleOutputEquals(publisher, expectedToken, timeout: 1)
    }

    func test_manualOAuth_refreshToken_refreshSucceeds() {
        let loginSession = LoginSession.mockManualOAuth()
        api.loginSession = loginSession
        guard let oauthType = loginSession.oauthType else {
            return XCTFail("OAuth type not set for login session")
        }
        let client = APIVerifyClient(
            authorized: true,
            base_url: api.baseURL,
            client_id: oauthType.clientID,
            client_secret: oauthType.clientSecret
        )
        let request = PostLoginOAuthRequest(
            oauthType: .manual(.init(client: client)),
            refreshToken: loginSession.refreshToken!
        )
        let response = APIOAuthToken(
            access_token: "new_access_token",
            refresh_token: "new_refresh_token",
            token_type: "new_token_type",
            user: .make(
                id: "new_id",
                name: "new_name",
                effectiveLocale: "new_locale",
                email: "new_email"
            ),
            real_user: .init(id: "new_real_id", name: "new_real_name"),
            expires_in: 0,
            canvas_region: "us-east-1"
        )
        api.mock(request, value: response)
        let expectedToken = loginSession.refresh(
            accessToken: response.access_token,
            expiresAt: Clock.now + response.expires_in!
        )

        // WHEN
        let publisher = testee.refreshAccessToken(api: api)

        // THEN
        XCTAssertSingleOutputEquals(publisher, expectedToken, timeout: 1)
    }

    // MARK: - Fail Scenarios

    func test_noLoginSession() {
        api.loginSession = nil

        let publisher = testee.refreshAccessToken(api: api)

        XCTAssertFailure(publisher)
    }

    func test_pkceOAuth_missingRefreshToken() {
        api.loginSession = .mockPKCEOAuth(refreshToken: nil)

        let publisher = testee.refreshAccessToken(api: api)

        XCTAssertFailure(publisher)
    }

    func test_manualOAuth_missingRefreshToken() {
        api.loginSession = .mockPKCEOAuth(refreshToken: nil)

        let publisher = testee.refreshAccessToken(api: api)

        XCTAssertFailure(publisher)
    }

    func test_manualOAuth_missingClientID() {
        api.loginSession = .mockManualOAuth(
            oauthType: .manual(.init(
                baseURL: api.baseURL,
                clientID: nil,
                clientSecret: "test_client_secret"
            ))
        )

        let publisher = testee.refreshAccessToken(api: api)

        XCTAssertFailure(publisher)
    }

    func test_manualOAuth_missingClientSecret() {
        api.loginSession = .mockManualOAuth(
            oauthType: .manual(.init(
                baseURL: api.baseURL,
                clientID: "test_client_id",
                clientSecret: nil
            ))
        )
        let publisher = testee.refreshAccessToken(api: api)

        XCTAssertFailure(publisher)
    }

    func test_unknownNetworkError() {
        let loginSession = LoginSession.mockManualOAuth()
        api.loginSession = loginSession
        guard let oauthType = loginSession.oauthType else {
            return XCTFail("OAuth type not set for login session")
        }
        let client = APIVerifyClient(
            authorized: true,
            base_url: api.baseURL,
            client_id: oauthType.clientID,
            client_secret: oauthType.clientSecret
        )
        let request = PostLoginOAuthRequest(
            oauthType: .manual(.init(client: client)),
            refreshToken: loginSession.refreshToken!
        )
        let expectedError = AccessTokenRefreshInteractor.TokenError.unknownError
        api.mock(request, error: expectedError)

        // WHEN
        let publisher = testee.refreshAccessToken(api: api)

        // THEN
        XCTAssertFailureEquals(publisher, expectedError)
    }

    func test_refreshTokenExpiredError() {
        let loginSession = LoginSession.mockManualOAuth()
        api.loginSession = loginSession
        guard let oauthType = loginSession.oauthType else {
            return XCTFail("OAuth type not set for login session")
        }
        let client = APIVerifyClient(
            authorized: true,
            base_url: api.baseURL,
            client_id: oauthType.clientID,
            client_secret: oauthType.clientSecret
        )
        let request = PostLoginOAuthRequest(
            oauthType: .manual(.init(client: client)),
            refreshToken: loginSession.refreshToken!
        )
        let expectedError = AccessTokenRefreshInteractor.TokenError.expiredRefreshToken
        let errorMessage = """
            {
                "error": "invalid_grant",
                "error_description": "Refresh token expired"
            }
        """.data(using: .utf8)
        api.mock(request, data: errorMessage)

        // WHEN
        let publisher = testee.refreshAccessToken(api: api)

        // THEN
        XCTAssertFailureEquals(publisher, expectedError)
    }
}

// MARK: - Mocks

extension LoginSession {
    static func mockManualOAuth(
        accessToken: String? = "test_access_token",
        baseURL: URL = .make("https://instructure.com"),
        expiresAt: Date? = Clock.now,
        lastUsedAt: Date = Clock.now,
        locale: String? = "en_US",
        masquerader: URL? = nil,
        refreshToken: String? = "test_refresh_token",
        userAvatarURL: URL? = .make(),
        userID: String = "test_user_id",
        userName: String = "Test User",
        userEmail: String? = "test@example.com",
        oauthType: OAuthType = .manual(
            .init(
                baseURL: .make("https://canvas.instructure.com"),
                clientID: "test_client_id",
                clientSecret: "test_client_secret"
            )
        ),
        isFakeStudent: Bool = false
    ) -> LoginSession {
        LoginSession(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: lastUsedAt,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            oauthType: oauthType,
            isFakeStudent: isFakeStudent
        )
    }

    static func mockPKCEOAuth(
        accessToken: String? = "test_access_token",
        baseURL: URL = .make("https://instructure.com"),
        expiresAt: Date? = Clock.now,
        lastUsedAt: Date = Clock.now,
        locale: String? = "en_US",
        masquerader: URL? = nil,
        refreshToken: String? = "test_refresh_token",
        userAvatarURL: URL? = .make(),
        userID: String = "test_user_id",
        userName: String = "Test User",
        userEmail: String? = "test@example.com",
        oauthType: OAuthType = .pkce(
            .init(
                baseURL: .make("https://canvas.instructure.com"),
                clientID: "test_client_id",
                codeVerifier: "test_code_verifier"
            )
        ),
        isFakeStudent: Bool = false
    ) -> LoginSession {
        LoginSession(
            accessToken: accessToken,
            baseURL: baseURL,
            expiresAt: expiresAt,
            lastUsedAt: lastUsedAt,
            locale: locale,
            masquerader: masquerader,
            refreshToken: refreshToken,
            userAvatarURL: userAvatarURL,
            userID: userID,
            userName: userName,
            userEmail: userEmail,
            oauthType: oauthType,
            isFakeStudent: isFakeStudent
        )
    }
}
