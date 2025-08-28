//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import TestsFoundation

class UIAlertControllerExtensionsTests: CoreTestCase {

    func testLoginErrorAlert_createsCorrectAlertWithActionsAndHandlers() throws {
        var cancelActionCalled = false
        var retryActionCalled = false

        // WHEN
        let alert = UIAlertController.loginErrorAlert(
            cancelAction: { cancelActionCalled = true },
            retryAction: { retryActionCalled = true }
        )
        let cancelAction = try XCTUnwrap(alert.actions.first { $0.style == .cancel } as? AlertAction)
        let retryAction = try XCTUnwrap(alert.actions.first { $0.style == .default } as? AlertAction)
        cancelAction.handler?(cancelAction)
        retryAction.handler?(retryAction)

        // THEN
        XCTAssertEqual(alert.preferredStyle, .alert)
        XCTAssertEqual(alert.title, "Oops, something went wrong")
        XCTAssertEqual(alert.message, "There was an error while logging you in. You can try again, or come back a bit later.")
        XCTAssertEqual(alert.actions.count, 2)
        XCTAssertEqual(cancelAction.title, "Logout")
        XCTAssertEqual(retryAction.title, "Retry")
        XCTAssertTrue(cancelActionCalled)
        XCTAssertTrue(retryActionCalled)
    }

    func testShowLoginErrorAlert_presentsAlert() throws {
        let viewController = UIViewController()
        let window = UIWindow()
        window.rootViewController = viewController
        AppEnvironment.shared.window = window

        UIAlertController.showLoginErrorAlert(
            cancelAction: {},
            retryAction: {}
        )

        let router = try XCTUnwrap(AppEnvironment.shared.router as? TestRouter)
        wait(for: [router.showExpectation])
        XCTAssertEqual(router.lastViewController is UIAlertController, true)
    }
}
