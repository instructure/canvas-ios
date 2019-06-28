//
// Copyright (C) 2019-present Instructure, Inc.
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
