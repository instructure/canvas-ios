//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class StudentSyllabusPresenterTests: StudentTestCase {

    var presenter: StudentSyllabusPresenter!
    var resultingError: NSError?
    var navigationController: UINavigationController?
    var courseCode: String?
    var backgroundColor: UIColor?
    var didCallShowAssignmentsOnly = false

    var navBarExpectation = XCTestExpectation(description: "navBarExpectation")
    var htmlExpectation = XCTestExpectation(description: "htmlExpectation")
    var assignmentsOnlyExpectation = XCTestExpectation(description: "assignmentsOnlyExpectation")

    override func setUp() {
        super.setUp()
        didCallShowAssignmentsOnly = false
        navBarExpectation = XCTestExpectation(description: "navBarExpectation")
        htmlExpectation = XCTestExpectation(description: "htmlExpectation")
        presenter = StudentSyllabusPresenter(courseID: "1", view: self, env: env)
    }

    func testLoadHtml() {
        //  given
        let expectedSyllabusHtml = "foobar"
        Course.make(from: .make(syllabus_body: expectedSyllabusHtml))

        //  when
        presenter.viewIsReady()
        wait(for: [htmlExpectation], timeout: 0.1)
    }

    func testLoadNavBarStuff() {
        //  given
        let course = Course.make(from: .make(course_code: "abc"))
        ContextColor.make(canvasContextID: course.canvasContextID)

        //  when
        presenter.viewIsReady()
        wait(for: [navBarExpectation], timeout: 0.1)
        //  then
        XCTAssertEqual(courseCode, "abc")
        XCTAssertEqual(backgroundColor, UIColor.red)
    }

    func testShowAssignmentsOnly() {
        //  given
        let expectedSyllabusHtml = ""
        Course.make(from: .make(syllabus_body: expectedSyllabusHtml))

        //  when
        presenter.viewIsReady()
        wait(for: [assignmentsOnlyExpectation], timeout: 0.1)
        //  then
        XCTAssertTrue(didCallShowAssignmentsOnly)
    }

    func testShowAssignmentsOnlyNotCalledWhenNoCourse() {
        //  given
        assignmentsOnlyExpectation.isInverted = true

        //  when
        presenter.viewIsReady()
        wait(for: [assignmentsOnlyExpectation], timeout: 0.1)
        //  then
        XCTAssertFalse(didCallShowAssignmentsOnly)
    }

    func testShowURL() {
        let url = URL(string: "https://canvas.instructure.com/courses/1/pages/page-one")!
        presenter.show(url, from: UIViewController())
        XCTAssertTrue(router.lastRoutedTo(url))
    }
}

extension StudentSyllabusPresenterTests: StudentSyllabusViewProtocol {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?) {
        self.courseCode = courseCode
        self.backgroundColor = backgroundColor
        navBarExpectation.fulfill()
    }

    func updateMenuHeight() {
        htmlExpectation.fulfill()
    }

    func showAssignmentsOnly() {
        didCallShowAssignmentsOnly = true
        assignmentsOnlyExpectation.fulfill()
    }
}
