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
import UIKit
import XCTest

class LoginAgainInteractorTests: CoreTestCase {
    var mockLoginAgainViewModel: LoginAgainViewModelMock!
    var testee: LoginAgainInteractor!
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        mockLoginAgainViewModel = LoginAgainViewModelMock()
        testee = LoginAgainInteractor(loginAgainViewModel: mockLoginAgainViewModel)
        XCTAssertNotNil(AppEnvironment.shared.window?.rootViewController)
        XCTAssertNotNil(api.loginSession?.baseURL.host(percentEncoded: false))
    }

    // MARK: - Success Scenario

    func test_publishedNewSession_afterUserLoggedIn() throws {
        let newSession = api.loginSession!.refresh(accessToken: UUID.string, expiresAt: .distantFuture)
        let streamFinished = expectation(description: "Stream finished")

        try testee.loginAgainOnExpiredRefreshToken(
            tokenRefreshError: AccessTokenRefreshInteractor.TokenError.expiredRefreshToken,
            api: api
        )
        .sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    streamFinished.fulfill()
                }
            },
            receiveValue: { session in
                XCTAssertEqual(session.userID, newSession.userID)
                XCTAssertEqual(session.accessToken, newSession.accessToken)
            }
        )
        .store(in: &subscriptions)

        mockLoginAgainViewModel.mockResultPublisher.send(newSession)

        wait(for: [streamFinished], timeout: 1)
    }

    func test_discoversTopViewController_toPresentLoginAgainViewController() throws {
        let rootViewController = try XCTUnwrap(AppEnvironment.shared.window?.rootViewController)
        let presentedViewController = UIViewController()
        rootViewController.present(presentedViewController, animated: false)

        try testee.loginAgainOnExpiredRefreshToken(
            tokenRefreshError: AccessTokenRefreshInteractor.TokenError.expiredRefreshToken,
            api: api
        )
        .ignoreOutput()
        .ignoreFailure()
        .sink()
        .store(in: &subscriptions)

        XCTAssertEqual(mockLoginAgainViewModel.receivedRootViewController, presentedViewController)
    }

    // MARK: - Failure Scenarios

    func test_reThrowsError_onInvalidHost() {
        api.loginSession = .mock(baseURL: .make())

        XCTAssertThrowsError(
            try testee.loginAgainOnExpiredRefreshToken(
                tokenRefreshError: NSError.internalError(),
                api: api
            )
        ) { error in
            XCTAssertEqual(error as NSError, NSError.internalError())
        }
    }

    func test_reThrowsError_onNoRootViewController() {
        AppEnvironment.shared.window?.rootViewController = nil

        XCTAssertThrowsError(
            try testee.loginAgainOnExpiredRefreshToken(
                tokenRefreshError: NSError.internalError(),
                api: api
            )
        ) { error in
            XCTAssertEqual(error as NSError, NSError.internalError())
        }
    }

    func test_reThrowsError_onUnknownError() {
        XCTAssertThrowsError(
            try testee.loginAgainOnExpiredRefreshToken(
                tokenRefreshError: NSError.internalError(),
                api: api
            )
        ) { error in
            XCTAssertEqual(error as NSError, NSError.internalError())
        }
    }

    func test_throwsError_whenLoggedInWithDifferentUser() throws {
        // baseURL, userID and masquerader are compared if the session belongs to the same user
        let differentUserSession = LoginSession.mock(
            baseURL: AppEnvironment.shared.currentSession!.baseURL,
            masquerader: AppEnvironment.shared.currentSession!.masquerader,
            userID: UUID.string
        )
        let streamFailed = expectation(description: "Stream failed")

        try testee.loginAgainOnExpiredRefreshToken(
            tokenRefreshError: AccessTokenRefreshInteractor.TokenError.expiredRefreshToken,
            api: api
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    XCTAssertEqual(failure, .loggedInWithDifferentUser)
                    streamFailed.fulfill()
                }
            },
            receiveValue: { _ in
                XCTFail("There should be no new session")
            }
        )
        .store(in: &subscriptions)

        mockLoginAgainViewModel.mockResultPublisher.send(differentUserSession)

        wait(for: [streamFailed], timeout: 1)
    }

    func test_reThrowsCancelError_whenUserCancelsLogin() throws {
        let streamFailed = expectation(description: "Stream failed")

        try testee.loginAgainOnExpiredRefreshToken(
            tokenRefreshError: AccessTokenRefreshInteractor.TokenError.expiredRefreshToken,
            api: api
        )
        .sink(
            receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    XCTAssertEqual(failure, .canceledByUser)
                    streamFailed.fulfill()
                }
            },
            receiveValue: { _ in
                XCTFail("There should be no new session")
            }
        )
        .store(in: &subscriptions)

        mockLoginAgainViewModel.mockResultPublisher.send(completion: .failure(.canceledByUser))

        wait(for: [streamFailed], timeout: 1)
    }
}

class LoginAgainViewModelMock: LoginAgainViewModel {
    var mockResultPublisher = PassthroughSubject<LoginSession, LoginAgainInteractor.LoginError>()
    var receivedRootViewController: UIViewController?

    override func askUserToLogin(
        host: String,
        rootViewController: UIViewController,
        router: Router
    ) -> AnyPublisher<LoginSession, LoginAgainInteractor.LoginError> {
        receivedRootViewController = rootViewController
        return mockResultPublisher.first().eraseToAnyPublisher()
    }
}
