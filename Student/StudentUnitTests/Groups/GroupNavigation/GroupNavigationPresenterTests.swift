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
import Core
@testable import Student
import TestsFoundation

class GroupNavigationPresenterTests: PersistenceTestCase {

    var resultingColor: UIColor?
    var resultingTitle = ""
    var resultingBackgroundColor: UIColor?
    let context = ContextModel(.group, id: "1")
    var presenter: GroupNavigationPresenter!
    var resultingError: NSError?
    var onUpdateNavBar: (() -> Void)?
    lazy var expectUpdateNavBar: XCTestExpectation = {
        let expect = XCTestExpectation(description: "updateNavBar called")
        expect.assertForOverFulfill = false
        return expect
    }()
    var onUpdate: (() -> Void)?
    var expectUpdate: XCTestExpectation!
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        presenter = GroupNavigationPresenter(groupID: context.id, view: self, env: env)
        expectUpdate = XCTestExpectation(description: "update called")
    }

    func testUseCaseSetupProperly() {
        XCTAssertEqual(presenter.groups.useCase.groupID, presenter.context.id)
        XCTAssertEqual(presenter.tabs.useCase.context.canvasContextID, presenter.context.canvasContextID)
    }

    func testLoadColor() {
        Group.make()
        ContextColor.make(canvasContextID: context.canvasContextID)

        presenter.color.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
        XCTAssertEqual(resultingColor, UIColor.red)
    }

    func testLoadGroup() {
        let group = Group.make()
        presenter.groups.eventHandler()
        XCTAssertEqual(resultingTitle, group.name)
    }

    func testLoadTabs() {
        let tab = Tab.make()
        presenter.tabs.eventHandler()
        wait(for: [expectUpdate], timeout: 0.1)
        XCTAssertEqual(presenter.tabs.first, tab)
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        let colorStore = presenter.color as! TestStore
        let groupStore = presenter.groups as! TestStore
        let tabsStore = presenter.tabs as! TestStore

        wait(for: [colorStore.refreshExpectation, groupStore.refreshExpectation, tabsStore.exhaustExpectation], timeout: 0.1)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", html_url: URL(string: "https://google.com/b")!, position: 2))
        Tab.make(from: .make(id: "c", html_url: URL(string: "https://google.com/c")!, position: 3))
        Tab.make(from: .make(id: "a", html_url: URL(string: "https://google.com/a")!, position: 1))

        presenter.tabs.eventHandler()
        wait(for: [expectUpdate], timeout: 0.1)

        XCTAssertEqual(presenter.tabs.count, 3)
        XCTAssertEqual(presenter.tabs.first?.id, "a")
        XCTAssertEqual(presenter.tabs.last?.id, "c")
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
        resultingTitle = title
        resultingBackgroundColor = backgroundColor
    }

    func update(color: UIColor) {
        resultingColor = color
        expectUpdate.fulfill()
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
