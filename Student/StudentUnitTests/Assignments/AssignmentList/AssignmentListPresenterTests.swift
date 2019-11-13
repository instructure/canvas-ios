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
@testable import Student
import Core
import TestsFoundation

class AssignmentListPresenterTests: StudentTestCase {

    var resultingError: NSError?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: AssignmentListPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var colorExpectation = XCTestExpectation(description: "expectation")

    var titleSubtitleView = TitleSubtitleView.create()
    var navigationItem: UINavigationItem = UINavigationItem(title: "")

    var title: String?
    var color: UIColor?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentListPresenter(env: env, view: self, courseID: "1")
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.course.useCase.courseID, presenter.courseID)

        XCTAssertEqual(presenter.assignments.useCase.courseID, presenter.courseID)
        XCTAssertEqual(presenter.assignments.useCase.sort, .position)
    }

    func testLoadColor() {
        let course = Course.make()
        ContextColor.make(canvasContextID: course.canvasContextID)
        presenter.color.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadCourse() {
        let course = Course.make()
        presenter.course.eventHandler()
        XCTAssertEqual(resultingSubtitle, course.name)
    }

    func testLoadAssignments() {
        Assignment.make()
        presenter.assignments.eventHandler()
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(presenter.assignments.count, 1)
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        let colorStore = presenter.color as! TestStore
        let courseStore = presenter.course as! TestStore
        let assignmentsStore = presenter.assignments as! TestStore

        wait(for: [colorStore.refreshExpectation, courseStore.refreshExpectation, assignmentsStore.exhaustExpectation], timeout: 0.1)
    }

    func testSelect() {
        let a = Assignment.make()
        let router = env.router as? TestRouter
        XCTAssertNoThrow(presenter.select(a, from: UIViewController()))
        XCTAssertEqual(router?.calls.last?.0, URLComponents.parse(a.htmlURL))
    }
}

extension AssignmentListPresenterTests: AssignmentListViewProtocol {
    func update() {
        expectation.fulfill()
    }

    var navigationController: UINavigationController? {
        return UINavigationController(nibName: nil, bundle: nil)
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, color: UIColor?) {
        resultingBackgroundColor = color
        resultingSubtitle = subtitle
        colorExpectation.fulfill()
    }
}
