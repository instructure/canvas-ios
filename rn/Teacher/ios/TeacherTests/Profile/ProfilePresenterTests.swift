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
@testable import Teacher
import TestsFoundation
@testable import Core
import CoreData

class ProfilePresenterTests: TeacherTestCase {
    class MockView: ProfileViewProtocol {
        var reloaded = 0
        func reload() {
            reloaded += 1
        }

        var routedTo: URLComponents?
        func route(to url: URLComponents, options: RouteOptions?) {
            routedTo = url
        }

        var helpShown = false
        func showHelpMenu(from cell: UITableViewCell) {
            helpShown = true
        }

        var presented: UIViewController?
        func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
            presented = viewControllerToPresent
        }

        var dismissed = false
        func dismiss(animated flag: Bool, completion: (() -> Void)?) {
            dismissed = true
        }

        func showError(_ error: Error) {}
        func showError(_ message: String) {}

        var navigationController: UINavigationController?
    }

    let view = MockView()

    lazy var presenter: ProfilePresenter = {
        let presenter = ProfilePresenter()
        presenter.view = view
        presenter.viewIsReady()
        return presenter
    }()

    func testActAsUserNoPermission() {
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: false))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "actAsUser" }))
    }

    func testActAsUserWithPermission() {
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: true))
        XCTAssertTrue(presenter.cells.contains(where: { $0.id == "actAsUser" }))
    }

    func testActAsUserInSiteadmin() {
        environment.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin.instructure.com")!)
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: true))
        XCTAssertTrue(presenter.cells.contains(where: { $0.id == "actAsUser" }))
    }
}
