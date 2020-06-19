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

class ProfileSettingsViewControllerTests: CoreTestCase {
    var vc: ProfileSettingsViewController!
    var externalURLOpened: URL?

    override func setUp() {
        super.setUp()
        vc = ProfileSettingsViewController.create()
    }

    func load() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
        vc.viewDidLoad()
        vc.viewWillAppear(false)
    }

    func testRender() {
        let channels = [
            APICommunicationChannel.make(address: "a", id: ID(1), position: 1, type: .email, workflow_state: .active),
            APICommunicationChannel.make(address: "b", id: ID(2), position: 2, type: .push, workflow_state: .active),
        ]
        api.mock(vc.profile, value: APIProfile.make())
        api.mock(vc.channels, value: channels)

        load()

        var cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Landing Page")
        XCTAssertEqual( cell?.detailTextLabel?.text, "Dashboard")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Email Notifications")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        wait(for: [router.showExpectation], timeout: 1)
        var (routedVC, _, _) = router.viewControllerCalls.last!
        XCTAssert(routedVC is NotificationCategoriesViewController)
        if let catViewController = routedVC as? NotificationCategoriesViewController {
            XCTAssertEqual(catViewController.channelType, CommunicationChannelType.email)
        } else { XCTFail() }

        cell = vc.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Push Notifications")

        cell = vc.tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Pair with Observer")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 3, section: 0))
        (routedVC, _, _) = router.viewControllerCalls.last!
        XCTAssert(routedVC is PairWithObserverViewController)

        let previousDelegate = environment.loginDelegate
        environment.loginDelegate = self
        cell = vc.tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Subscribe to Calendar Feed")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 4, section: 0))
        environment.loginDelegate = previousDelegate
        XCTAssertEqual(externalURLOpened, URL(string: "https://calendar.url"))

        cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Privacy Policy")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
        XCTAssert(router.lastRoutedTo(.parse("https://www.instructure.com/policies/privacy/")))

        cell = vc.tableView.cellForRow(at: IndexPath(row: 1, section: 1)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Terms of Use")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 1, section: 1))
        XCTAssert(router.lastRoutedTo("/accounts/self/terms_of_service"))

        cell = vc.tableView.cellForRow(at: IndexPath(row: 2, section: 1)) as? RightDetailTableViewCell
        XCTAssertEqual( cell?.textLabel?.text, "Canvas on GitHub")
        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 2, section: 1))
        XCTAssert(router.lastRoutedTo(.parse("https://github.com/instructure/canvas-ios")))
    }
}

extension ProfileSettingsViewControllerTests: LoginDelegate {
    func userDidLogin(session: LoginSession) {
    }

    func userDidLogout(session: LoginSession) {
    }

    func openExternalURL(_ url: URL) {
        externalURLOpened = url
    }
}
