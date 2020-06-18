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
import SafariServices
import XCTest
@testable import Core
import TestsFoundation

class ProfileViewControllerTests: CoreTestCase, LoginDelegate {
    lazy var controller = ProfileViewController.create(enrollment: .student)

    var notificationPayload: [AnyHashable: Any]?
    func reduxActionCalled(notification: Notification) {
        notificationPayload = notification.userInfo
    }

    var defaultsDidChange = false
    func userDefaultsDidChange(notification: Notification) {
        defaultsDidChange = true
    }

    var externalURL: URL?
    func openExternalURL(_ url: URL) {
        externalURL = url
    }

    func userDidLogin(session: LoginSession) {}

    var didLogout = false
    func userDidLogout(session: LoginSession) {
         didLogout = true
    }

    var didChangeUser = false
    func changeUser() {
        didChangeUser = true
    }

    override func setUp() {
        super.setUp()
        api.mock(controller.helpLinks, value: nil)
        api.mock(controller.permissions, value: .make(become_user: true))
        api.mock(controller.tools, value: [])
        api.mock(controller.settings, value: .make())
        api.mock(controller.profile, value: .make(
            name: "Eve",
            primary_email: "automated-test-Eve@instructure.com",
            avatar_url: URL(string: "https://localhost/avatar.png")!,
            pronouns: nil
        ))
        api.mock(GetUserRequest(userID: "self"), value: .make())
        api.mock(PutUserSettingsRequest(), value: .make())

        let n = NSNotification.Name("redux-action")
        NotificationCenter.default.addObserver(self, selector: #selector(reduxActionCalled(notification:)), name: n, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange(notification:)), name: UserDefaults.didChangeNotification, object: nil)
    }

    func testLayout() {
        controller.view.layoutIfNeeded()

        XCTAssertEqual(controller.emailLabel.text, "automated-test-Eve@instructure.com")
        XCTAssertEqual(controller.nameLabel.text, "Eve")
        XCTAssertEqual(controller.avatarButton.isHidden, false)
        XCTAssertEqual(controller.avatarView.name, "Eve")
        XCTAssertEqual(controller.avatarView.url?.absoluteString, "https://localhost/avatar.png")

        XCTAssertEqual(controller.tableView.numberOfRows(inSection: 0), 8)

        var index = IndexPath(row: 0, section: 0)
        var cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Files")
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(router.lastRoutedTo("/users/self/files"))

        index = IndexPath(row: 1, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Show Grades")
        let existingValue = environment.userDefaults?.showGradesOnDashboard ?? false
        (cell?.accessoryView as? UISwitch)?.isOn = !existingValue
        (cell?.accessoryView as? UISwitch)?.sendActions(for: .valueChanged)
        XCTAssertEqual(environment.userDefaults?.showGradesOnDashboard, !existingValue)
        XCTAssertTrue(defaultsDidChange)

        index = IndexPath(row: 2, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Color Overlay")
        controller.tableView(controller.tableView, didSelectRowAt: index)
        let type = notificationPayload?["type"] as? String
        let payload = notificationPayload?["payload"] as? [String: Bool]
        XCTAssertEqual(type, "userInfo.updateUserSettings")
        XCTAssertEqual(payload?["hideOverlay"], true)

        index = IndexPath(row: 3, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Settings")
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(router.lastRoutedTo("/profile/settings"))

        index = IndexPath(row: 4, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Act as User")
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(router.lastRoutedTo("/act-as-user"))

        index = IndexPath(row: 5, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Change User")
        let prevDelegate = environment.loginDelegate
        environment.loginDelegate = self
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(didChangeUser)
        environment.loginDelegate = prevDelegate

        index = IndexPath(row: 6, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Log Out")
        environment.loginDelegate = self
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(didLogout)
        environment.loginDelegate = prevDelegate

        controller.didTapVersion()
        XCTAssertEqual(UserDefaults.standard.bool(forKey: "showDevMenu"), true)
        index = IndexPath(row: 7, section: 0)
        cell = controller.tableView.cellForRow(at: index) as? ProfileTableViewCell
        XCTAssertEqual(cell?.nameLabel.text, "Developer Menu")
        controller.tableView(controller.tableView, didSelectRowAt: index)
        XCTAssertTrue(router.lastRoutedTo("/dev-menu"))

    }

    func testPronouns() {
        api.mock(controller.profile, value: .make(
            name: "Eve",
            primary_email: "automated-test-Eve@instructure.com",
            pronouns: "She/Her")
        )
        AppEnvironment.shared.currentSession = LoginSession.make(
            userAvatarURL: URL(string: "https://localhost/avatar.png")!,
            userEmail: "automated-test-Eve@instructure.com"
        )
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.emailLabel.text, "automated-test-Eve@instructure.com")
        XCTAssertEqual(controller.nameLabel.text, "Eve (She/Her)")
        XCTAssertEqual(controller.avatarView.name, "Eve")
    }

    func testChangeAvatarDisallowed() {
        api.mock(GetUserRequest(userID: "self"), value: .make(permissions: .make(can_update_avatar: false)))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.avatarButton.isHidden, true)
    }

    func testActAsUserNoPermission() {
        api.mock(controller.permissions, value: nil)
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "actAsUser" }))
    }

    func testActAsUserInSiteadmin() {
        environment.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin.instructure.com")!)
        api.mock(controller.permissions, value: nil)
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.cells.contains(where: { $0.id == "actAsUser" }))
    }

    func testLogout() {
        login.session = currentSession
        controller.view.layoutIfNeeded()
        controller.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell())
        XCTAssertNil(login.session)
        login.session = currentSession
        controller.cells.first(where: { $0.id == "changeUser" })?.block(UITableViewCell())
        XCTAssertTrue(login.userChanged)
        environment.currentSession = nil
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell()))
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "changeUser" })?.block(UITableViewCell()))
    }

    func testStopActing() {
        currentSession = LoginSession.make(masquerader: URL(string: "https://canvas.instructure.com/users/5"))
        environment.currentSession = currentSession
        login.session = currentSession
        controller.view.layoutIfNeeded()
        controller.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell())
        XCTAssertNil(login.session)
        environment.currentSession = nil
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell()))
    }

    func testNoExtras() {
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "help" }))
        XCTAssertFalse(controller.cells.contains(where: { $0.id.hasPrefix("lti") }))
    }

    func testHelp() {
        api.mock(controller.helpLinks, value: .make())
        controller.view.layoutIfNeeded()
        controller.cells.first(where: { $0.id == "help" })?.block(UITableViewCell())
        let alert = router.presented as? UIAlertController
        XCTAssertEqual(alert?.title, "Help")
        XCTAssertEqual(alert?.actions[0].title, "Ask Your Instructor a Question")
        (alert?.actions[0] as? AlertAction)?.handler?(AlertAction())
        XCTAssert(router.lastRoutedTo(
            "/conversations/compose?instructorQuestion=1&canAddRecipients="
        ))
        XCTAssertEqual(alert?.actions[1].title, "Search the Canvas Guides")
        (alert?.actions[1] as? AlertAction)?.handler?(AlertAction())
        XCTAssert(router.lastRoutedTo(URL(string:
            "http://community.canvaslms.com/community/answers/guides"
        )!))
        XCTAssertEqual(alert?.actions[2].title, "Report a Problem")
        (alert?.actions[2] as? AlertAction)?.handler?(AlertAction())
        XCTAssert(router.lastRoutedTo("/support/problem"))
    }

    func testLTI() {
        let sessionless = URL(string: "https://canvas.instructure.com/sessionless")!
        api.mock(controller.tools, value: [
            APIExternalToolLaunch(definition_id: "1", domain: "arc.instructure.com", placements: [
                "global_navigation": APIExternalToolLaunchPlacement(title: "Studio", url: URL(string: "/")!),
            ]),
        ])
        api.mock(LTITools(url: URL(string: "/")).request, value: .make(url: sessionless))
        controller.view.layoutIfNeeded()
        controller.cells.first(where: { $0.id.hasPrefix("lti") })?.block(UITableViewCell())
        XCTAssert(router.presented is SFSafariViewController)
    }

    func testObserver() {
        controller.enrollment = .observer
        controller.view.layoutIfNeeded()
        controller.cells.first(where: { $0.id == "inbox" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/conversations"))
        controller.cells.first(where: { $0.id == "manageChildren" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/profile/observees"))
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "files" }))
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "colorOverlay" }))
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "settings" }))
        controller.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/dev-menu"))
    }

    func testStudent() {
        controller.enrollment = .student
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "manageChildren" }))
        controller.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/users/self/files"))
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "showGrades" })?.block(UITableViewCell()))
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        controller.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/profile/settings"))
        controller.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/dev-menu"))
    }

    func testTeacher() {
        controller.enrollment = .teacher
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "manageChildren" }))
        controller.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/users/self/files"))
        XCTAssertFalse(controller.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertNoThrow(controller.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        controller.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/profile/settings"))
        controller.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssert(router.lastRoutedTo("/dev-menu"))
    }

    func testUpdateAvatar() {
        controller.view.layoutIfNeeded()
        controller.avatarButton.sendActions(for: .primaryActionTriggered)
        let menu = router.presented as? UIAlertController
        XCTAssertEqual(menu?.title, "Choose Profile Picture")
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            XCTAssertEqual(menu?.actions[0].title, "Take Photo")
            (menu?.actions[0] as? AlertAction)?.handler?(AlertAction())
            let picker = router.presented as? UIImagePickerController
            XCTAssertEqual(picker?.sourceType, .camera)
        }
        XCTAssertEqual(menu?.actions[1].title, "Choose Photo")
        (menu?.actions[1] as? AlertAction)?.handler?(AlertAction())
        let picker = router.presented as? UIImagePickerController
        XCTAssertEqual(picker?.sourceType, .photoLibrary)

        api.mock(PostFileUploadTargetRequest(context: .myFiles, body: .init(
            name: "profile",
            on_duplicate: .rename,
            size: 1
        )), value: .make())
        api.mock(PostFileUploadRequest(fileURL: Bundle(for: Self.self).url(forResource: "TestImage", withExtension: "png")!, target: .make()), value: .make())
        api.mock(GetFileRequest(context: .currentUser, fileID: "1", include: [ .avatar ]), value: .make(avatar: APIFileToken(token: "t")))
        api.mock(PutUserAvatarRequest(token: "t"), value: .make())
        picker?.delegate?.imagePickerController?(picker!, didFinishPickingMediaWithInfo: [
            .originalImage: UIImage.icon(.instructure),
        ])
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Internal Error")

        api.mock(PutUserAvatarRequest(token: "t"), value: .make(avatar_url: URL(string: "https://c.i.com/newone")))
        picker?.delegate?.imagePickerController?(picker!, didFinishPickingMediaWithInfo: [
            .originalImage: UIImage.icon(.instructure),
        ])
        XCTAssertEqual(controller.avatarView.url?.absoluteString, "https://c.i.com/newone")

        XCTAssertNoThrow(picker?.delegate?.imagePickerControllerDidCancel?(picker!))
    }
}
