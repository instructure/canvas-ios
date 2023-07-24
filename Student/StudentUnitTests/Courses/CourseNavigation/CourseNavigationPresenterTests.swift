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

class CourseNavigationPresenterTests: StudentTestCase {
    let context = Context(.course, id: "1")
    var presenter: CourseNavigationPresenter!
    var resultingError: NSError?
    var navigationController: UINavigationController?
    var resultingTitle: String?
    var resultingBackgroundColor: UIColor?

    var onUpdate: (() -> Void)?
    lazy var expectUpdate: XCTestExpectation = {
        let expect = XCTestExpectation(description: "update called")
        expect.assertForOverFulfill = false
        return expect
    }()

    override func setUp() {
        super.setUp()
        env.mockStore = true
        presenter = CourseNavigationPresenter(courseID: context.id, view: self, env: env)
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.courses.useCase.courseID, presenter.context.id)
        XCTAssertEqual(presenter.tabs.useCase.context.canvasContextID, presenter.context.canvasContextID)
    }

    func testLoadColor() {
        Course.make()
        ContextColor.make()

        presenter.color.eventHandler()
        XCTAssertEqual(resultingBackgroundColor!.hexString, UIColor.red.ensureContrast(against: .backgroundLightest).hexString)
    }

    func testLoadCourse() {
        let course = Course.make()
        presenter.courses.eventHandler()
        XCTAssertEqual(resultingTitle, course.name)
    }

    func testLoadTabs() {
        let tab = Tab.make(from: .make(label: "tab"), context: context)
        presenter.tabs.eventHandler()
        wait(for: [expectUpdate], timeout: 0.1)
        XCTAssertEqual(presenter.tabs.first?.label, tab.label)
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        let colorStore = presenter.color as! TestStore
        let courseStore = presenter.courses as! TestStore
        let tabStore = presenter.tabs as! TestStore
        wait(for: [colorStore.refreshExpectation, courseStore.refreshExpectation, tabStore.exhaustExpectation], timeout: 0.1)
    }

    func testTabsAreOrderedByPosition() {
        Tab.make(from: .make(id: "b", html_url: URL(string: "https://google.com/b")!, position: 2), context: context)
        Tab.make(from: .make(id: "c", html_url: URL(string: "https://google.com/c")!, position: 3), context: context)
        Tab.make(from: .make(id: "a", html_url: URL(string: "https://google.com/a")!, position: 1), context: context)

        presenter.tabs.eventHandler()
        wait(for: [expectUpdate], timeout: 0.1)
        XCTAssertEqual(presenter.tabs.count, 3)
        XCTAssertEqual(presenter.tabs.first?.id, "a")
        XCTAssertEqual(presenter.tabs.last?.id, "c")
    }
}

extension CourseNavigationPresenterTests: CourseNavigationViewProtocol {
    func updateNavBar(title: String?, backgroundColor: UIColor?) {
        resultingTitle = title
        resultingBackgroundColor = backgroundColor
    }

    func update() {
        expectUpdate.fulfill()
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }
}
