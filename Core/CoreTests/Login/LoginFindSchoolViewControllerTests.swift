//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class LoginFindSchoolViewControllerTests: CoreTestCase {
    var helpURL = URL(string: "https://canvas.instructure.com/help")
    var opened: URL?
    let first = IndexPath(row: 0, section: 0)

    lazy var controller = LoginFindSchoolViewController.create(loginDelegate: self, method: .normalLogin)

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "lastLoginAccount")
        super.tearDown()
    }

    func testResults() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        controller.viewDidAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        let cell = controller.resultsTableView.cellForRow(at: first)
        XCTAssertEqual(cell?.textLabel?.text, "How do I find my school?")
        controller.resultsTableView.delegate?.tableView?(controller.resultsTableView, didSelectRowAt: first)
        XCTAssertEqual(opened, helpURL)
        opened = nil

        controller.searchField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.resultsTableView.cellForRow(at: first)?.textLabel?.text, "How do I find my school?")

        api.mock(GetAccountsSearchRequest(searchTerm: "nope"))
        controller.searchField.text = "nope"
        controller.searchField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.resultsTableView.cellForRow(at: first)?.textLabel?.text, "Can’t find your school? Try typing the full school URL. Login help.")
        controller.resultsTableView.delegate?.tableView?(controller.resultsTableView, didSelectRowAt: first)
        XCTAssertEqual(opened, helpURL)

        api.mock(GetAccountsSearchRequest(searchTerm: "cgnu"), value: [.make(name: "Crazy Go Nuts University")])
        controller.searchField.text = "cgnu"
        controller.searchField.sendActions(for: .editingChanged)
        XCTAssertEqual(controller.resultsTableView.cellForRow(at: first)?.textLabel?.text, "Crazy Go Nuts University")
        controller.resultsTableView.delegate?.tableView?(controller.resultsTableView, didSelectRowAt: first)
        let shown = router.viewControllerCalls.first?.0 as? LoginWebViewController
        XCTAssertEqual(shown?.host, "cgnuonline-eniversity.edu")
    }

    func testManualOAuth() {
        controller.method = .manualOAuthLogin
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.searchField.delegate?.textFieldShouldReturn?(controller.searchField), false)
        XCTAssert(router.viewControllerCalls.isEmpty)
        controller.searchField.text = "test"
        XCTAssertEqual(controller.searchField.delegate?.textFieldShouldReturn?(controller.searchField), false)
        let shown = router.viewControllerCalls.first?.0 as? LoginManualOAuthViewController
        XCTAssertEqual(shown?.host, "test.instructure.com")
    }

    func testNextButtonHiddenByDefault() {
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }

    func testNextButtonAppearsOnSearchFieldType() {
        controller.view.layoutIfNeeded()
        controller.searchField.text = "asd"
        controller.textFieldDidChange(controller.searchField)
        XCTAssertNotNil(controller.navigationItem.rightBarButtonItem)
    }

    func testNextButtonDisappearsOnEmptySearchField() {
        controller.view.layoutIfNeeded()
        controller.searchField.text = "asd"
        controller.searchField.sendActions(for: .editingChanged)
        controller.searchField.text = ""
        controller.searchField.sendActions(for: .editingChanged)
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }

    func testNextButtonShowsLoginScreen() {
        controller.view.layoutIfNeeded()
        controller.searchField.text = "asd"
        controller.searchField.sendActions(for: .editingChanged)
        controller.perform(controller.navigationItem.rightBarButtonItem!.action)
        let shown = router.viewControllerCalls.first?.0 as? LoginWebViewController
        XCTAssertEqual(shown?.host, "asd.instructure.com")
    }
}

extension LoginFindSchoolViewControllerTests: LoginDelegate {
    func openExternalURL(_ url: URL) {
        opened = url
    }
    func userDidLogin(session: LoginSession) {}
    func userDidLogout(session: LoginSession) {}
}
