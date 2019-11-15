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
@testable import Core

class SyllabusPresenterTests: CoreTestCase {

    var presenter: SyllabusPresenter!
    var html: String? = ""
    var courseCode: String?
    var htmlExpectation = XCTestExpectation(description: "htmlExpectation")

    override func setUp() {
        super.setUp()
        html = ""
        htmlExpectation = XCTestExpectation(description: "htmlExpectation")
        environment.mockStore = false
        presenter = SyllabusPresenter(view: self, courseID: "1", env: environment)
    }

    func testLoadHtml() {
        //  given
        let expectedSyllabusHtml = "foobar"
        Course.make(from: .make(syllabus_body: expectedSyllabusHtml))

        //  when
        presenter.viewIsReady()
        wait(for: [htmlExpectation], timeout: 0.1)
        //  then
        XCTAssertEqual(html, expectedSyllabusHtml)
    }

}

extension SyllabusPresenterTests: SyllabusViewProtocol {
    func loadHtml(_ html: String?) {
        self.html = html
        htmlExpectation.fulfill()
    }
}
