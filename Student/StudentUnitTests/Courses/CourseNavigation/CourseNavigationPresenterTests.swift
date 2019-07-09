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
        Course.make()
        let expected = tab()
        let expectation = XCTestExpectation(description: "loaded tab")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.tabs.first?.id == expected.id {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", position: 2), context: ContextModel(.course, id: "1"))
        Tab.make(from: .make(id: "c", position: 3), context: ContextModel(.course, id: "1"))
        Tab.make(from: .make(id: "a", position: 1), context: ContextModel(.course, id: "1"))

        let expectation = XCTestExpectation(description: "orders by position")
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
