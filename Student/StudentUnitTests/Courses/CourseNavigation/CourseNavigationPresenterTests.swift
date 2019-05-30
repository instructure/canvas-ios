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

class CourseNavigationPresenterTests: PersistenceTestCase {
    lazy var presenter = CourseNavigationPresenter(courseID: "1", view: self, env: env)
    var resultingError: NSError?
    var navigationController: UINavigationController?

    var onUpdate: (() -> Void)?
    lazy var expectUpdate: XCTestExpectation = {
        let expect = XCTestExpectation(description: "update called")
        expect.assertForOverFulfill = false
        return expect
    }()

    @discardableResult
    func tab() -> Tab {
        return Tab.make(context: ContextModel(.course, id: "1"))
    }

    func testLoadTabs() {
        //  given
        Course.make()
        let expected = tab()

        //  when
        presenter.viewIsReady()
        wait(for: [expectUpdate], timeout: 1)
        //  then
        XCTAssertEqual(presenter.tabs.first?.id, expected.id)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", position: 2), context: ContextModel(.course, id: "1"))
        Tab.make(from: .make(id: "c", position: 3), context: ContextModel(.course, id: "1"))
        Tab.make(from: .make(id: "a", position: 1), context: ContextModel(.course, id: "1"))

        presenter.viewIsReady()
        wait(for: [expectUpdate], timeout: 1)

        XCTAssertEqual(presenter.tabs.count, 3)
        XCTAssertEqual(presenter.tabs.first?.id, "a")
        XCTAssertEqual(presenter.tabs.last?.id, "c")
    }

    func testUseCaseFetchesData() {
        let tab = self.tab()
        let expectation = XCTestExpectation(description: "fetches data")
        onUpdate = {
            if self.presenter.tabs.first?.label == tab.label {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }
}

extension CourseNavigationPresenterTests: CourseNavigationViewProtocol {
    func updateNavBar(title: String?, backgroundColor: UIColor?) {
    }

    func update() {
        onUpdate?()
        expectUpdate.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
