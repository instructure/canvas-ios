//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import TestsFoundation

class LoginNavigationControllerTests: CoreTestCase {
    lazy var controller = LoginNavigationController.create(loginDelegate: self, fromLaunch: false, app: .student)

    func testLogin() {
        controller.view.layoutIfNeeded()
        XCTAssert(controller.viewControllers.first is LoginStartViewController)
        XCTAssertTrue(controller.isNavigationBarHidden)

        controller.login(host: "canvas.instructure.com")
        XCTAssert(controller.viewControllers[0] is LoginStartViewController)
        XCTAssert(controller.viewControllers[1] is LoginFindSchoolViewController)
        XCTAssertEqual((controller.viewControllers[2] as? LoginWebViewController)?.host, "canvas.instructure.com")
    }
}

extension LoginNavigationControllerTests: LoginDelegate {
    var helpURL: URL? { return nil }
    func openExternalURL(_ url: URL) {}
    func userDidLogin(session: LoginSession) {}
    func userDidLogout(session: LoginSession) {}
}
