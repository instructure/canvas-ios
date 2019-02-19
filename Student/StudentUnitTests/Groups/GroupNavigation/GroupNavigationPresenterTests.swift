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

    var resultingTabs: [GroupNavigationViewModel]?
    var resultingColor: UIColor?
    var resultingTitle = ""
    var presenter: GroupNavigationPresenter!
    var resultingError: NSError?
    var expectation = XCTestExpectation(description: "expectation")
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = GroupNavigationPresenter(groupID: Group.make().id, view: self, env: env, useCase: MockUseCase {})
    }

    func testLoadTabs() {
        //  given
        Group.make()
        let expected = Tab.make()

        //  when
        presenter.loadTabs()

        //  then
        XCTAssertEqual(resultingTabs?.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(["position": 2, "id": "b"])
        Tab.make(["position": 3, "id": "c"])
        Tab.make(["position": 1, "id": "a"])

        presenter.loadTabs()

        XCTAssertEqual(resultingTabs?.count, 3)
        XCTAssertEqual(resultingTabs?.first?.id, "a")
        XCTAssertEqual(resultingTabs?.last?.id, "c")
    }

    func testUseCaseFetchesData() {
        //  given
        var color: Color!
        var group: Group!
        let useCase = MockUseCase {
            group = Group.make()
            color = Color.make(["canvasContextID": group.canvasContextID, "color": UIColor.init(hexString: "#ff0")])
            Tab.make()
            self.expectation.fulfill()
        }

        presenter = GroupNavigationPresenter(groupID: Group.make().id, view: self, env: env, useCase: useCase)

       //   when
        presenter.loadTabs()
        wait(for: [expectation], timeout: 1)

        //  then
        XCTAssertEqual(resultingTabs?.first?.label, Tab.make().label)
        XCTAssertEqual(resultingTabs?.first?.icon.renderingMode, .alwaysTemplate)
        XCTAssertEqual(resultingTitle, group.name)
        XCTAssertEqual(resultingColor, color.color )
    }
}

extension GroupNavigationPresenterTests: GroupNavigationViewProtocol {
    func updateNavBar(title: String, backgroundColor: UIColor) {
        resultingTitle = title
    }

    func showTabs(_ tabs: [GroupNavigationViewModel], color: UIColor) {
        resultingTabs = tabs
        resultingColor = color
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
