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
    lazy var presenter = GroupNavigationPresenter(groupID: Group.make().id, view: self, env: env)
    var resultingError: NSError?
    var onUpdateNavBar: (() -> Void)?
    lazy var expectUpdateNavBar: XCTestExpectation = {
        let expect = XCTestExpectation(description: "updateNavBar called")
        expect.assertForOverFulfill = false
        return expect
    }()
    var onUpdate: (() -> Void)?
    lazy var expectUpdate: XCTestExpectation = {
        let expect = XCTestExpectation(description: "update called")
        expect.assertForOverFulfill = false
        return expect
    }()
    var navigationController: UINavigationController?

    func testLoadTabs() {
        //  given
        Group.make()
        let expected = Tab.make()

        //  when
        let expectation = XCTestExpectation(description: "on update")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.tabs.first?.id == expected.id {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()

        // then
        wait(for: [expectation], timeout: 1)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", position: 2), context: ContextModel(.group, id: "1"))
        Tab.make(from: .make(id: "c", position: 3), context: ContextModel(.group, id: "1"))
        Tab.make(from: .make(id: "a", position: 1), context: ContextModel(.group, id: "1"))
        let expectation = XCTestExpectation(description: "on update")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.tabs.count == 3,
                self.presenter.tabs.first?.id == "a",
                self.presenter.tabs.last?.id == "c" {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }

    func testUseCaseFetchesData() {
        let group = Group.make()
        let color = Color.make(canvasContextID: group.canvasContextID, color: UIColor(hexString: "#ff0")!)
        Tab.make()

        let expectData = XCTestExpectation(description: "fetches data")
        expectData.assertForOverFulfill = false
        let expectTitle = XCTestExpectation(description: "fetches group")
        expectTitle.assertForOverFulfill = false
        onUpdateNavBar = {
            if self.resultingTitle == group.name {
                expectTitle.fulfill()
            }
        }
        onUpdate = {
            if self.resultingColor == color.color && self.presenter.tabs.count == 1 {
                expectData.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectData, expectTitle], timeout: 1)
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
        resultingTitle = title
        onUpdateNavBar?()
        expectUpdateNavBar.fulfill()
    }

    func update(color: UIColor) {
        resultingColor = color
        onUpdate?()
        expectUpdate.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
