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
import TestsFoundation

class TokenRefreshInteractorTests: CoreTestCase {
    var mockAccessTokenRefreshInteractor: MockAccessTokenRefreshInteractor!
    var mockLoginAgainInteractor: MockLoginAgainInteractor!
    var testee: TokenRefreshInteractor!

    let refreshedSession = LoginSession.mock(accessToken: "newAccessToken", refreshToken: "newRefreshToken")
    let expiredSession = LoginSession.mock(accessToken: "oldAccessToken", refreshToken: "oldRefreshToken")

    override func setUp() {
        super.setUp()
        mockAccessTokenRefreshInteractor = MockAccessTokenRefreshInteractor()
        mockLoginAgainInteractor = MockLoginAgainInteractor()
        testee = TokenRefreshInteractor(
            api: api,
            accessTokenRefreshInteractor: mockAccessTokenRefreshInteractor,
            loginAgainInteractor: mockLoginAgainInteractor,
            scheduler: DispatchQueue.immediate.eraseToAnyScheduler()
        )
        api.loginSession = expiredSession
        AppEnvironment.shared.currentSession = expiredSession
    }

    // MARK: - Success Scenarios

    func test_accessTokenRenewalSucceeds() {
        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedSession)

        // THEN
        XCTAssertEqual(api.loginSession?.accessToken, refreshedSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedSession.accessToken)
    }

    func test_refreshesRefreshToken_whenItExpired() {
        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedSession)

        // THEN
        XCTAssertEqual(api.loginSession?.accessToken, refreshedSession.accessToken)
        XCTAssertEqual(api.loginSession?.refreshToken, refreshedSession.refreshToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.accessToken, refreshedSession.accessToken)
        XCTAssertEqual(AppEnvironment.shared.currentSession?.refreshToken, refreshedSession.refreshToken)
    }

    func test_executesQueuedRequests_whenAccessTokenRefreshSucceeds() {
        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(refreshedSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    func test_executesQueuedRequests_whenRefreshTokenRefreshSucceeds() {
        let queuedRequest = expectation(description: "Request should be canceled")
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedSession)

        // THEN
        waitForExpectations(timeout: 1)
    }

    // MARK: - Failure Scenarios

    func test_logout_whenUserCancelsReLogin() {
        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.canceledByUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_logout_whenUserLogsInWithDifferentUser() {
        let queuedRequest = expectation(description: "Request should be canceled")
        queuedRequest.isInverted = true
        testee.addRequestWaitingForToken {
            queuedRequest.fulfill()
        }
        login.session = expiredSession

        // WHEN
        testee.refreshToken()
        mockAccessTokenRefreshInteractor.mockResultPublisher.send(completion: .failure(.expiredRefreshToken))
        mockLoginAgainInteractor.mockResultPublisher.send(completion: .failure(.loggedInWithDifferentUser))

        // THEN
        waitForExpectations(timeout: 1)
        XCTAssertNil(login.session)
    }

    func test_releasesQueuedRequests_onNetworkFailure() {
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

    override func refreshAccessToken(api: API) -> AnyPublisher<LoginSession, TokenError> {
        mockResultPublisher
            .first()
            .eraseToAnyPublisher()
    }
}

class MockLoginAgainInteractor: LoginAgainInteractor {
    var mockResultPublisher = PassthroughSubject<LoginSession, LoginAgainInteractor.LoginError>()
    var mockedThrownError: Error?

    override func loginAgainOnExpiredRefreshToken(
        tokenRefreshError: Error,
        api: API
    ) throws -> AnyPublisher<LoginSession, LoginAgainInteractor.LoginError> {
        if let mockedThrownError {
            throw mockedThrownError
        }
        return mockResultPublisher.first().eraseToAnyPublisher()
    }
}
