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

import XCTest
import Core
@testable import Student
import TestsFoundation

class SyllabusPresenterTests: PersistenceTestCase {

    var presenter: SyllabusPresenter!
    var resultingError: NSError?
    var navigationController: UINavigationController?
    var html: String?
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
        presenter = SyllabusPresenter(courseID: "1", view: self, env: env)
    }

    func testLoadHtml() {
        //  given
        let expectedSyllabusHtml = "foobar"
        Course.make(from: .make(syllabus_body: expectedSyllabusHtml))

        //  when
        presenter.viewIsReady()
        wait(for: [htmlExpectation], timeout: 0.1)
        //  then
        XCTAssertEqual(expectedSyllabusHtml, html)
    }

    func testLoadNavBarStuff() {
        //  given
        let course = Course.make(from: .make(course_code: "abc"))
        Color.make(canvasContextID: course.canvasContextID)

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

extension SyllabusPresenterTests: SyllabuseViewProtocol {
    func updateNavBar(courseCode: String?, backgroundColor: UIColor?) {
        self.courseCode = courseCode
        self.backgroundColor = backgroundColor
        navBarExpectation.fulfill()
    }

    func loadHtml(_ html: String?) {
        self.html = html
        htmlExpectation.fulfill()
    }

    func showAssignmentsOnly() {
        didCallShowAssignmentsOnly = true
        assignmentsOnlyExpectation.fulfill()
    }
}
