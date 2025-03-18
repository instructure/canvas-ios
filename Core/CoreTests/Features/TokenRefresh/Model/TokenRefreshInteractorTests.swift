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

    func test_manualLogin_afterAccessTokenRenewalFailed() {
        let mockAccessTokenRefreshInteractor = MockAccessTokenRefreshInteractor()
        mockAccessTokenRefreshInteractor.mockResult = .failure(.expiredRefreshToken)
        let refreshedToken = LoginSession.mock(refreshToken: "refreshed!")
        let mockLoginAgainInteractor = MockLoginAgainInteractor()
        let expiredSession = LoginSession.mock(refreshToken: "oldToken")
        let api = API()
        api.loginSession = expiredSession
        AppEnvironment.shared.currentSession = expiredSession
        let testee = TokenRefreshInteractor(
            api: api,
            accessTokenRefreshInteractor: mockAccessTokenRefreshInteractor,
            loginAgainInteractor: mockLoginAgainInteractor,
            scheduler: DispatchQueue.immediate.eraseToAnyScheduler()
        )
        api.refreshTokenInteractor = testee
        let requestFailedExpectation = expectation(description: "Request failed due to expired auth token")
        let requestTriedAgainExpectation = expectation(description: "Request tried again")
        var requestCount = 0
        let request = GetCourseRequest(courseID: "1")
        let successResponseData = APICourse.make()
        api.mock(request) { _ in
            requestCount += 1
            switch requestCount {
            case 1:
                let unauthorizedResponse = HTTPURLResponse(
                    url: .make(),
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: nil
                )
                requestFailedExpectation.fulfill()
                return (nil, unauthorizedResponse, nil)
            case 2:
                requestTriedAgainExpectation.fulfill()
                return (successResponseData, nil, nil)
            default:
                XCTFail("Invalid invocation count \(requestCount)")
                return (nil, nil, nil)
            }
        }
        let requestCompletedExpectation = expectation(description: "Request completed")

        // WHEN
        api.makeRequest(request) { response, urlResponse, error in
            requestCompletedExpectation.fulfill()
            XCTAssertEqual(response, successResponseData)
            XCTAssertNil(urlResponse)
            XCTAssertNil(error)
        }

        // THEN
        wait(for: [requestFailedExpectation], timeout: 1)
        waitUntil(1, shouldFail: true) {
            testee.isTokenRefreshInProgress == true &&
            mockAccessTokenRefreshInteractor.receivedAPI === api
        }

        // WHEN
        mockLoginAgainInteractor.mockResultPublisher.send(refreshedToken)

        // THEN
        wait(for: [requestTriedAgainExpectation, requestCompletedExpectation], timeout: 1)
        XCTAssertEqual(testee.isTokenRefreshInProgress, false)
    }
}

private class MockAccessTokenRefreshInteractor: AccessTokenRefreshInteractor {
    var mockResult: Result<LoginSession, TokenError>?

    private(set) var receivedAPI: API?

    override func refreshAccessToken(api: API) -> AnyPublisher<LoginSession, TokenError> {
        receivedAPI = api

        return Future<LoginSession, TokenError> { promise in
            guard let result = self.mockResult else {
                return assertionFailure("no mock found")
            }
            promise(result)
        }
        .eraseToAnyPublisher()
    }
}

private class MockLoginAgainInteractor: LoginAgainInteractor {
    var mockResultPublisher = PassthroughSubject<LoginSession, LoginAgainInteractor.LoginError>()

    override func loginAgainOnExpiredRefreshToken(
        tokenRefreshError: Error,
        api: API
    ) -> AnyPublisher<LoginSession, LoginAgainInteractor.LoginError> {
        return mockResultPublisher.first().eraseToAnyPublisher()
    }
}
