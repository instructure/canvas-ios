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

class LoginAgainViewModelTests: CoreTestCase {
    var subscriptions = Set<AnyCancellable>()
    let rootViewController = UIViewController()
    let newSession = LoginSession.make(refreshToken: "refreshed!")

    func test_loginFlow() throws {
        let testee = LoginAgainViewModel()
        let newSessionReceived = expectation(description: "New session received")
        let streamCompleted = expectation(description: "Stream completed")

        // WHEN
        testee
            .askUserToLogin(
                host: "https://instructure.com",
                rootViewController: rootViewController,
                router: router
            )
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        streamCompleted.fulfill()
                    }
                },
                receiveValue: { [newSession] session in
                    XCTAssertEqual(session, newSession)
                    newSessionReceived.fulfill()
                }
            )
            .store(in: &subscriptions)

        // THEN
        waitUntil(1) { router.presented is UIAlertController }
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        let okAction = try XCTUnwrap(alert.actions.first as? AlertAction)

        // WHEN - User taps on OK button
        okAction.handler?(okAction)

        // THEN - Login Screen gets presented
        waitUntil(1) { router.presented is LoginWebViewController }
        let loginController = try XCTUnwrap(router.presented as? LoginWebViewController)

        // WHEN - User logs in
        loginController.loginCompletion?(newSession)

        // THEN - Stream returns new session
        wait(for: [newSessionReceived, streamCompleted], timeout: 1)
    }

    func test_showsSessionExpiredDialog() throws {
        let streamPublishes = expectation(description: "New session received")
        let streamCompleted = expectation(description: "Stream completed")

        // WHEN - Asking for the dialog
        LoginAgainViewModel
            .showSessionExpiredDialog(
                rootViewController: rootViewController,
                router: router
            )
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        streamCompleted.fulfill()
                    }
                },
                receiveValue: {
                    streamPublishes.fulfill()
                }
            )
            .store(in: &subscriptions)

        // THEN - Alert is presented
        waitUntil(1) { router.presented is UIAlertController }
        let alert = try XCTUnwrap(router.presented as? UIAlertController)
        XCTAssertEqual(router.viewControllerCalls.last?.0, alert)
        XCTAssertEqual(router.viewControllerCalls.last?.1, rootViewController)
        XCTAssertEqual(
            alert.message,
            "You'll need to log in again due to your institute's security policy.\nOnce logged in, you can continue working seamlessly."
        )
        XCTAssertEqual(alert.title, nil)
        XCTAssertEqual(alert.actions.count, 1)
        let okAction = try XCTUnwrap(alert.actions.first as? AlertAction)
        XCTAssertEqual(okAction.title, "OK")
        XCTAssertEqual(okAction.style, .default)

        // WHEN - User taps on OK button
        okAction.handler?(okAction)

        // THEN - Stream finishes
        wait(for: [streamPublishes, streamCompleted], timeout: 1)
    }

    func test_webViewLogin_successful() throws {
        let newSessionReceived = expectation(description: "New session received")
        let streamCompleted = expectation(description: "Stream completed")

        LoginAgainViewModel
            .showLoginWebViewController(
                host: "https://instructure.com",
                rootViewController: rootViewController,
                router: router
            )
            .sink(
                receiveCompletion: { completion in
                    if case .finished = completion {
                        streamCompleted.fulfill()
                    }
                },
                receiveValue: { [newSession] session in
                    XCTAssertEqual(session, newSession)
                    newSessionReceived.fulfill()
                }
            )
            .store(in: &subscriptions)

        // THEN - Login Screen gets presented
        waitUntil(1) { router.presented is LoginWebViewController }
        let loginController = try XCTUnwrap(router.presented as? LoginWebViewController)
        XCTAssertEqual(router.viewControllerCalls.last?.0, loginController)
        XCTAssertEqual(router.viewControllerCalls.last?.1, rootViewController)
        XCTAssertEqual(
            router.viewControllerCalls.last?.2,
            .modal(
                isDismissable: false,
                embedInNav: true,
                addDoneButton: false,
                animated: true
            )
        )

        // WHEN - User logs in
        loginController.loginCompletion?(newSession)

        // THEN - Stream returns new session and dialog dimisses
        wait(for: [newSessionReceived, streamCompleted], timeout: 1)
        XCTAssertEqual(router.dismissed, loginController)
    }

    func test_webViewLogin_canceledByUser() throws {
        let streamFailed = expectation(description: "Stream failed")

        LoginAgainViewModel
            .showLoginWebViewController(
                host: "https://instructure.com",
                rootViewController: rootViewController,
                router: router
            )
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTAssertEqual(error, .canceledByUser)
                        streamFailed.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("New session shouldn't be received")
                }
            )
            .store(in: &subscriptions)

        // WHEN - User cancels
        waitUntil(1) { router.presented is LoginWebViewController }
        let loginController = try XCTUnwrap(router.presented as? LoginWebViewController)
        let cancelButton = try XCTUnwrap(loginController.navigationItem.rightBarButtonItem as? UIBarButtonItemWithCompletion)
        cancelButton.buttonDidTap(sender: cancelButton)

        wait(for: [streamFailed], timeout: 1)
    }
}
