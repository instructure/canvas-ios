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

import UIKit
import XCTest
@testable import Core
import TestsFoundation

class ProfileViewControllerTests: CoreTestCase {

    var vc: ProfileViewController!
    var notificationPayload: [AnyHashable: Any]?
    var didChangeUser = false
    var didLogout = false

    override func setUp() {
        super.setUp()
        vc = ProfileViewController.create(env: environment, enrollment: .student)
        notificationPayload = nil
        didChangeUser = false
        didLogout = false
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRender() {
        //  given
        AppEnvironment.shared.currentSession = LoginSession.make(userAvatarURL: URL(string: "https://localhost/avatar.png")!)
        //  when
        loadView()

        //  then
        XCTAssertEqual(vc.emailLabel?.text, "automated-test-Eve@instructure.com")
        XCTAssertEqual(vc.nameLabel?.text, "Eve")
        XCTAssertEqual(vc.avatarView?.name, "Eve")
        XCTAssertEqual(vc.avatarView?.url?.absoluteString, "https://localhost/avatar.png")

        XCTAssertEqual(vc.tableView?.numberOfRows(inSection: 0), 7)

        var cell = vc.tableView?.cellForRow(at: IndexPath(row: 0, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Files")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 1, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Show Grades")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 2, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Color Overlay")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 3, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Settings")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 4, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Change User")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 5, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Log Out")

        cell = vc.tableView?.cellForRow(at: IndexPath(row: 6, section: 0)) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel?.text, "Developer Menu")

        //  files
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(router.lastRoutedTo(Route.files()))

        let n = NSNotification.Name("redux-action")
        NotificationCenter.default.addObserver(self, selector: #selector(reduxActionCalled(notification:)), name: n, object: nil)

        //  show grades
        let existingValue = environment.userDefaults?.showGradesOnDashboard ?? false
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(environment.userDefaults?.showGradesOnDashboard, !existingValue)
        XCTAssertNotNil(notificationPayload)
        var type: String? = notificationPayload?["type"] as? String
        var payload: [String: Bool]? = notificationPayload?["payload"] as? [String: Bool]
        XCTAssertEqual(type, "userInfo.updateShowGradesOnDashboard")
        XCTAssertEqual(payload?["showsGradesOnCourseCards"], !existingValue)

        //  color overlay
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 2, section: 0))
        type = notificationPayload?["type"] as? String
        payload = notificationPayload?["payload"] as? [String: Bool]
        XCTAssertEqual(type, "userInfo.updateUserSettings")
        XCTAssertEqual(payload?["hideOverlay"], true)

        //  settings
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 3, section: 0))
        XCTAssertTrue(router.lastRoutedTo(Route.profileSettings))

        //  change user
        let prevDelegate = environment.loginDelegate
        environment.loginDelegate = self
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 4, section: 0))
        XCTAssertTrue(didChangeUser)
        environment.loginDelegate = prevDelegate

        // logout
        environment.loginDelegate = self
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 5, section: 0))
        XCTAssertTrue(didLogout)
        environment.loginDelegate = prevDelegate

        // developer menu
        vc.tableView(vc.tableView!, didSelectRowAt: IndexPath(row: 6, section: 0))
        XCTAssertTrue(router.lastRoutedTo(Route.developerMenu))
    }

    func reduxActionCalled(notification: Notification) {
        notificationPayload = notification.userInfo
    }
}

extension ProfileViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {

    }

    func userDidLogin(session: LoginSession) {

    }

    func userDidLogout(session: LoginSession) {
         didLogout = true
    }

    func changeUser() {
        didChangeUser = true
    }
}
