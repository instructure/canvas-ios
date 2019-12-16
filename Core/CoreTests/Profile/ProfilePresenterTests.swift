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
    lazy var view = MockView(self)

    override func setUp() {
        super.setUp()
        ExperimentalFeature.parentInbox.isEnabled = true
        api.mock(GetAccountHelpLinksRequest(), value: nil)
        api.mock(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make(become_user: false))
        api.mock(GetGlobalNavExternalToolsRequest(), value: [])
        api.mock(GetUserSettingsRequest(userID: "self"), value: .make())
    }

    lazy var presenter: ProfilePresenter = {
        environment.mockStore = false
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
        view.expect(route: Route.actAsUser) {
            presenter.cells.first(where: { $0.id == "actAsUser" })?.block(UITableViewCell())
        }
    }

    func testActAsUserInSiteadmin() {
        environment.currentSession = LoginSession.make(baseURL: URL(string: "https://siteadmin.instructure.com")!)
        view.expect(route: Route.actAsUser) {
            presenter.cells.first(where: { $0.id == "actAsUser" })?.block(UITableViewCell())
        }
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
        view.expect(route: Route.developerMenu) {
            presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        }
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
        wait(for: [view.helpShown], timeout: 5)
        presenter.cells.first(where: { $0.id.hasPrefix("lti") })?.block(UITableViewCell())
        wait(for: [view.ltiExpectation], timeout: 5)
    }

    func testObserver() {
        enrollment = .observer
        view.expect(route: Route.conversations) {
            presenter.cells.first(where: { $0.id == "inbox" })?.block(UITableViewCell())
        }
        view.expect(route: Route.profileObservees) {
            presenter.cells.first(where: { $0.id == "manageChildren" })?.block(UITableViewCell())
        }
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "files" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "colorOverlay" }))
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "settings" }))
        view.expect(route: Route.developerMenu) {
            presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        }
    }

    func testStudent() {
        enrollment = .student
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "manageChildren" }))
        view.expect(route: Route.files()) {
            presenter.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        }
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "showGrades" })?.block(UITableViewCell()))
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        view.expect(route: Route.profileSettings) {
            presenter.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        }
        view.expect(route: Route.developerMenu) {
            presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        }
    }

    func testTeacher() {
        enrollment = .teacher
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "manageChildren" }))
        view.expect(route: Route.files()) {
            presenter.cells.first(where: { $0.id == "files" })?.block(UITableViewCell())
        }
        XCTAssertFalse(presenter.cells.contains(where: { $0.id == "showGrades" }))
        XCTAssertNoThrow(presenter.cells.first(where: { $0.id == "colorOverlay" })?.block(UITableViewCell()))
        view.expect(route: Route.profileSettings) {
            presenter.cells.first(where: { $0.id == "settings" })?.block(UITableViewCell())
        }
        view.expect(route: Route.developerMenu) {
            presenter.cells.first(where: { $0.id == "developerMenu" })?.block(UITableViewCell())
        }
    }

    class MockView: ProfileViewProtocol {
        let testCase: XCTestCase

        init(_ testCase: XCTestCase) {
            self.testCase = testCase
        }

        var onReload: (() -> Void)?
        var reloaded = 0
        func reload() {
            reloaded += 1
            onReload?()
        }

        func expect(route: Route, file: StaticString = #file, line: UInt = #line, block: () -> Void) {
            routeExpectation = XCTestExpectation(description: "route to \(route)")
            block()
            testCase.wait(for: [routeExpectation!], timeout: 5)
            XCTAssertEqual(routedTo, route, file: file, line: line)
        }

        var routedTo: Route?
        var routeExpectation: XCTestExpectation?
        func route(to: Route, options: RouteOptions?) {
            routedTo = to
            routeExpectation?.fulfill()
        }

        let helpShown = XCTestExpectation(description: "help shown")
        func showHelpMenu(from cell: UITableViewCell) {
            helpShown.fulfill()
        }

        var teacherSettingsShown = false
        func showTeacherSettingsMenu(from cell: UITableViewCell) {
            teacherSettingsShown = true
        }

        let ltiExpectation = XCTestExpectation(description: "lti launched")
        func launchLTI(url: URL) {
            ltiExpectation.fulfill()
        }

        func showError(_ error: Error) {}
        func showError(_ message: String) {}

        func showAlert(title: String?, message: String?) {}

        func dismiss(animated flag: Bool, completion: (() -> Void)?) {
            completion?()
        }
    }
}
