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
    let context = ContextModel(.course, id: "1")
    lazy var presenter = CourseNavigationPresenter(courseID: context.id, view: self, env: env)
    var resultingError: NSError?
    var navigationController: UINavigationController?

    var onUpdate: (() -> Void)?
    lazy var expectUpdate: XCTestExpectation = {
        let expect = XCTestExpectation(description: "update called")
        expect.assertForOverFulfill = false
        return expect
    }()

    func testLoadTabs() {
        Course.make()
        api.mock(GetTabsRequest(context: context), value: [.make(label: "Tab")])

        let expectation = XCTestExpectation(description: "loaded tab")
        expectation.assertForOverFulfill = false
        onUpdate = {
            if self.presenter.tabs.first?.label == "Tab" {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)
    }

    func testTabsAreOrderedByPosition() {
        api.mock(GetTabsRequest(context: context), value: [
            .make(id: "b", html_url: URL(string: "https://google.com/b")!, position: 2),
            .make(id: "c", html_url: URL(string: "https://google.com/c")!, position: 3),
            .make(id: "a", html_url: URL(string: "https://google.com/a")!, position: 1),
        ])

        let expectation = XCTestExpectation(description: "orders by position")
        expectation.assertForOverFulfill = false
        onUpdate = {
            print(self.presenter.tabs.count)
            if self.presenter.tabs.count == 3,
                self.presenter.tabs.first?.id == "a",
                self.presenter.tabs.last?.id == "c" {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)
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
