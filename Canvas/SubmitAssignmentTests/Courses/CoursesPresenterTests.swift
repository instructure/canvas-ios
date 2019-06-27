//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Core
import TestsFoundation
import XCTest

class CoursesPresenterTests: SubmitAssignmentTests, CoursesView {
    func testViewIsReady() {
        let presenter = CoursesPresenter(environment: env, selectedCourseID: nil, callback: { _ in })
        presenter.view = self
        let expectation = XCTestExpectation(description: "update was called")
        Course.make()
        onUpdate = {
            if !presenter.courses.isEmpty {
                expectation.fulfill()
            }
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)
    }

    func testCallback() {
        Course.make(from: .make(name: "Selected Course"))
        let expectation = XCTestExpectation(description: "callback was called")
        var course: Course?
        let presenter = CoursesPresenter(environment: env, selectedCourseID: nil) { c in
            course = c
            expectation.fulfill()
        }
        presenter.view = self
        presenter.viewIsReady()
        presenter.selectCourse(at: IndexPath(row: 0, section: 0))
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(course)
        XCTAssertEqual(course?.name, "Selected Course")
    }

    func testGetNextPage() {
        let expectation = XCTestExpectation(description: "update was not called")
        expectation.isInverted = true
        onUpdate = {
            expectation.fulfill()
        }
        let presenter = CoursesPresenter(environment: env, selectedCourseID: nil, callback: { _ in })
        presenter.view = self
        presenter.getNextPage()
        wait(for: [expectation], timeout: 0.1)
    }

    func testSelectedCourseID() {
        let selected = CoursesPresenter(environment: env, selectedCourseID: "1", callback: { _ in })
        XCTAssertEqual(selected.selectedCourseID, "1")

        let notSelected = CoursesPresenter(environment: env, selectedCourseID: nil, callback: { _ in })
        XCTAssertEqual(notSelected.selectedCourseID, nil)
    }

    var onUpdate: () -> Void = {}
    func update() {
        onUpdate()
    }
}
