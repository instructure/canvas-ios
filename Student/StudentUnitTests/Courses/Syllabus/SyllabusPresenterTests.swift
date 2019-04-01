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

    var navBarExpectation = XCTestExpectation(description: "navBarExpectation")
    var htmlExpectation = XCTestExpectation(description: "htmlExpectation")

    override func setUp() {
        super.setUp()
        navBarExpectation = XCTestExpectation(description: "navBarExpectation")
        htmlExpectation = XCTestExpectation(description: "htmlExpectation")
        presenter = SyllabusPresenter(courseID: "1", view: self, env: env)
    }

    func testLoadHtml() {
        //  given
        let expectedSyllabusHtml = "foobar"
        Course.make(["syllabusBody": expectedSyllabusHtml])

        //  when
        presenter.viewIsReady()
        wait(for: [htmlExpectation], timeout: 0.1)
        //  then
        XCTAssertEqual(expectedSyllabusHtml, html)
    }

    func testLoadNavBarStuff() {
        //  given
        let course = Course.make(["courseCode": "abc"])
        Color.make([#keyPath(Color.canvasContextID): course.canvasContextID])

        //  when
        presenter.viewIsReady()
        wait(for: [navBarExpectation], timeout: 0.1)
        //  then
        XCTAssertEqual(courseCode, "abc")
        XCTAssertEqual(backgroundColor, UIColor.red)
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
}
