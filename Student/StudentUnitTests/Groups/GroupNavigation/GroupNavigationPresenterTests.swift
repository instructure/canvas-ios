//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
    lazy var expectUpdateNavBar: XCTestExpectation = {
        let expect = expectation(description: "updateNavBar called")
        expect.assertForOverFulfill = false
        return expect
    }()
    lazy var expectUpdate: XCTestExpectation = {
        let expect = expectation(description: "update called")
        expect.assertForOverFulfill = false
        return expect
    }()
    var navigationController: UINavigationController?

    func testLoadTabs() {
        //  given
        Group.make()
        let expected = Tab.make()

        //  when
        presenter.viewIsReady()
        wait(for: [expectUpdate, expectUpdateNavBar], timeout: 1)

        //  then
        XCTAssertEqual(presenter.tabs.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", position: 2), context: ContextModel(.group, id: "1"))
        Tab.make(from: .make(id: "c", position: 3), context: ContextModel(.group, id: "1"))
        Tab.make(from: .make(id: "a", position: 1), context: ContextModel(.group, id: "1"))
        presenter.viewIsReady()
        wait(for: [expectUpdate, expectUpdateNavBar], timeout: 1)

        XCTAssertEqual(presenter.tabs.count, 3)
        XCTAssertEqual(presenter.tabs.first?.id, "a")
        XCTAssertEqual(presenter.tabs.last?.id, "c", "\(String(describing: presenter.tabs.last?.id)) was the last" )
    }

    func testUseCaseFetchesData() {
        //  given
        let group = Group.make()
        let color = Color.make(canvasContextID: group.canvasContextID, color: UIColor(hexString: "#ff0")!)
        Tab.make()

       //   when
        presenter.viewIsReady()
        wait(for: [expectUpdate, expectUpdateNavBar], timeout: 1)

        //  then
        XCTAssertEqual(presenter.tabs.first?.label, Tab.make().label)
        XCTAssertEqual(presenter.tabs.first?.icon.renderingMode, .alwaysTemplate)
        XCTAssertEqual(resultingTitle, group.name)
        XCTAssertEqual(resultingColor, color.color )
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
        resultingTitle = title
        expectUpdateNavBar.fulfill()
    }

    func update(color: UIColor) {
        resultingColor = color
        expectUpdate.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
