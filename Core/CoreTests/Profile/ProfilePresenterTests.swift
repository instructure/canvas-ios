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
import TestsFoundation
@testable import Core

class ProfilePresenterTests: CoreTestCase {
    var enrollment = HelpLinkEnrollment.student
    let view = MockView()

    override func setUp() {
        super.setUp()
        api.mock(GetAccountHelpLinksRequest(), value: nil)
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: false))
        api.mock(GetGlobalNavExternalToolsRequest(), value: [])
        api.mock(GetUserSettingsRequest(userID: "self"), value: .make())
    }

    lazy var presenter: ProfilePresenter = {
        let presenter = ProfilePresenter(enrollment: enrollment, view: view)
        let ready = expectation(description: "stores ready")
        ready.assertForOverFulfill = false
        view.onReload = {
            if (
                !presenter.helpLinks.pending &&
                !presenter.permissions.pending &&
                !presenter.settings.pending &&
                !presenter.tools.pending
            ) { ready.fulfill() }
        }
        presenter.viewIsReady()
        wait(for: [ ready ], timeout: 1)
        return presenter
    }()

    func testActAsUserNoPermission() {
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: nil)
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "actAsUser" }))
    }

    func testActAsUserWithPermission() {
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: true))
        presenter.cells.first(where: { $0.id == "actAsUser" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.actAsUser)
    }

    func testActAsUserInSiteadmin() {
        environment.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin.instructure.com")!)
        presenter.cells.first(where: { $0.id == "actAsUser" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.actAsUser)
    }

    func testLogout() {
        login.session = currentSession
        presenter.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell())
        XCTAssertNil(login.session)
        login.session = currentSession
        presenter.cells.first(where: { $0.id == "changeUser" })?.block(UITableViewCell())
        XCTAssertTrue(login.userChanged)
        environment.currentSession = nil
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell()))
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "changeUser" })?.block(UITableViewCell()))
    }

    func testStopActing() {
        currentSession = LoginSession.make(masquerader: URL(string: "https://canvas.instructure.com/users/5"))
        environment.currentSession = currentSession
        login.session = currentSession
        presenter.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell())
        XCTAssertNil(login.session)
        environment.currentSession = nil
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "logOut" })?.block(UITableViewCell()))
    }

    func testDidTapVersion() {
        presenter.showDevMenu = false
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "developerMenu" }))
        presenter.didTapVersion()
        XCTAssertTrue(presenter.showDevMenu)
        presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.developerMenu)
    }

    func testNoExtras() {
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "help" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id.hasPrefix("lti") }))
    }

    func testExtras() {
        api.mock(GetAccountHelpLinksRequest(), value: .make())
        api.mock(GetGlobalNavExternalToolsRequest(), value: [
            APIExternalToolLaunch(definition_id: "1", domain: "arc.instructure.com", placements: [
                "global_navigation": APIExternalToolLaunchPlacement(title: "Studio", url: URL(string: "/")!),
            ]),
        ])
        presenter.cells.first(where: { $0.id == "help" })?.block(UITableViewCell())
        XCTAssertTrue(view.helpShown)
        presenter.cells.first(where: { $0.id.hasPrefix("lti") })?.block(UITableViewCell())
        XCTAssertNotNil(view.lti)
    }

    func testObserver() {
        enrollment = .observer
        presenter.cells.first(where: { $0.id == "manageChildren" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.profileObservees)
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "files" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "colorOverlay" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "settings" }))
        presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.developerMenu)
    }

    func testStudent() {
        enrollment = .student
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "manageChildren" }))
        presenter.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.files())
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "showGrades" })?.block(UITableViewCell()))
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        presenter.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.profileSettings)
        presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.developerMenu)
    }

    func testTeacher() {
        enrollment = .teacher
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "manageChildren" }))
        presenter.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.files())
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        presenter.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        XCTAssertTrue(view.teacherSettingsShown)
        presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        XCTAssertEqual(view.routedTo, Route.developerMenu)
    }

    class MockView: ProfileViewProtocol {
        var onReload: (() -> Void)?
        var reloaded = 0
        func reload() {
            reloaded += 1
            onReload?()
        }

        var routedTo: Route?
        func route(to: Route, options: RouteOptions?) {
            routedTo = to
        }

        var helpShown = false
        func showHelpMenu(from cell: UITableViewCell) {
            helpShown = true
        }

        var teacherSettingsShown = false
        func showTeacherSettingsMenu(from cell: UITableViewCell) {
            teacherSettingsShown = true
        }

        var lti: URL?
        func launchLTI(url: URL) {
            lti = url
        }

        func showError(_ error: Error) {}
        func showError(_ message: String) {}

        var navigationController: UINavigationController?
    }
}
