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
import TestsFoundation
import XCTest

class TokenRefreshInteractorTests: CoreTestCase {
    var mockAccessTokenRefreshInteractor: MockAccessTokenRefreshInteractor!
    var mockLoginAgainInteractor: MockLoginAgainInteractor!
    var testee: TokenRefreshInteractor!

    let refreshedManualOAuthSession = LoginSession.mockManualOAuth(accessToken: "newAccessToken", refreshToken: "newRefreshToken")
    let expiredManualOAuthSession = LoginSession.mockManualOAuth(accessToken: "oldAccessToken", refreshToken: "oldRefreshToken")

    let refreshedPKCEOAuthSession = LoginSession.mockPKCEOAuth(accessToken: "newAccessToken", refreshToken: "newRefreshToken")
    let expiredPKCEOAuthSession = LoginSession.mockPKCEOAuth(accessToken: "oldAccessToken", refreshToken: "oldRefreshToken")

    override func setUp() {
        super.setUp()
        mockAccessTokenRefreshInteractor = MockAccessTokenRefreshInteractor()
        mockLoginAgainInteractor = MockLoginAgainInteractor()
        testee = TokenRefreshInteractor(
            api: api,
            accessTokenRefreshInteractor: mockAccessTokenRefreshInteractor,
            loginAgainInteractor: mockLoginAgainInteractor,
            mainThread: DispatchQueue.immediate.eraseToAnyScheduler()
        )
    }

    private func setManualOAuthSessions() {
        api.loginSession = expiredManualOAuthSession
        AppEnvironment.shared.currentSession = refreshedManualOAuthSession
    }

    private func setPKCEOAuthSessions() {
        api.loginSession = expiredPKCEOAuthSession
        AppEnvironment.shared.currentSession = refreshedPKCEOAuthSession
    }

    // MARK: - Success Scenarios

    func test_pkceOAuth_accessTokenRenewalSucceeds() {
        // GIVEN
        setPKCEOAuthSessions()

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedPKCEOAuthSession)

        // THEN
        waitUntil(1, shouldFail: true) { !testee.isTokenRefreshInProgress() }
        XCTAssertEqual(api.loginSession?.accessToken, refreshedPKCEOAuthSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedPKCEOAuthSession.accessToken)
    }

    func test_manualOAuth_accessTokenRenewalSucceeds() {
        // GIVEN
        setManualOAuthSessions()

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedManualOAuthSession)

        // THEN
        waitUntil(1, shouldFail: true) { !testee.isTokenRefreshInProgress() }
        XCTAssertEqual(api.loginSession?.accessToken, refreshedManualOAuthSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedManualOAuthSession.accessToken)
    }

    func test_pkceOAuth_refreshesRefreshToken_whenItExpired() {
        // GIVEN
        setPKCEOAuthSessions()

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedPKCEOAuthSession)

        // THEN
        waitUntil(1, shouldFail: true) { !testee.isTokenRefreshInProgress() }
        XCTAssertEqual(api.loginSession?.accessToken, refreshedPKCEOAuthSession.accessToken)
        XCTAssertEqual(api.loginSession?.refreshToken, refreshedPKCEOAuthSession.refreshToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedPKCEOAuthSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.refreshToken, refreshedPKCEOAuthSession.refreshToken)
    }

    func test_manualOAuth_refreshesRefreshToken_whenItExpired() {
        // GIVEN
        setManualOAuthSessions()

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedManualOAuthSession)

        // THEN
        waitUntil(1, shouldFail: true) { !testee.isTokenRefreshInProgress() }
        XCTAssertEqual(api.loginSession?.accessToken, refreshedManualOAuthSession.accessToken)
        XCTAssertEqual(api.loginSession?.refreshToken, refreshedManualOAuthSession.refreshToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedManualOAuthSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.refreshToken, refreshedManualOAuthSession.refreshToken)
    }

    func test_pkceOAuth_executesQueuedRequests_whenAccessTokenRefreshSucceeds() {
        setPKCEOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedPKCEOAuthSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func test_manualOAuth_executesQueuedRequests_whenAccessTokenRefreshSucceeds() {
        setManualOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedManualOAuthSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func test_pkceOAuth_executesQueuedRequests_whenRefreshTokenRefreshSucceeds() {
        // GIVEN
        setPKCEOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedPKCEOAuthSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func test_manualOAuth_executesQueuedRequests_whenRefreshTokenRefreshSucceeds() {
        // GIVEN
        setManualOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedManualOAuthSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    // MARK: - Failure Scenarios

    func test_pkceOAuth_logout_whenUserCancelsReLogin() {
        // GIVEN
        setPKCEOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredPKCEOAuthSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.canceledByUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_manualOAuth_logout_whenUserCancelsReLogin() {
        // GIVEN
        setManualOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredManualOAuthSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.canceledByUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_pkceOAuth_logout_whenUserLogsInWithDifferentUser() {
        // GIVEN
        setPKCEOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredPKCEOAuthSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.loggedInWithDifferentUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_manualOAuth_logout_whenUserLogsInWithDifferentUser() {
        // GIVEN
        setManualOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredManualOAuthSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.loggedInWithDifferentUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_pkceOAuth_releasesQueuedRequests_onNetworkFailure() {
        // GIVEN
        setPKCEOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockLoginAgainInteractor.mockedThrownError = NSError.internalError()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.unknownError))

        // THEN
        waitForExpectations(timeout: 1)
    }

    func test_manualOAuth_releasesQueuedRequests_onNetworkFailure() {
        // GIVEN
        setManualOAuthSessions()

        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockLoginAgainInteractor.mockedThrownError = NSError.internalError()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.unknownError))

        // THEN
        waitForExpectations(timeout: 1)
    }
}

class MockAccessTokenRefreshInteractor: AccessTokenRefreshInteractor {
    var mockResultPublisher = PassthroughSubject<LoginSession, TokenError>()

    override func refreshAccessToken(api _: API) -> AnyPublisher<LoginSession, TokenError> {
        mockResultPublisher
            .first()
            .eraseToAnyPublisher()
    }
}

class MockLoginAgainInteractor: LoginAgainInteractor {
    var mockResultPublisher = PassthroughSubject<LoginSession, LoginAgainInteractor.LoginError>()
    var mockedThrownError: Error?

    override func loginAgainOnExpiredRefreshToken(
        tokenRefreshError _: Error,
        api _: API
    ) throws -> AnyPublisher<LoginSession, LoginAgainInteractor.LoginError> {
        if let mockedThrownError {
            throw mockedThrownError
        }
        return mockResultPublisher.first().eraseToAnyPublisher()
    }
}
