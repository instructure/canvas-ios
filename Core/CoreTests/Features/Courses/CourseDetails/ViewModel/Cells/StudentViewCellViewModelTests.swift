//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import XCTest

class StudentViewCellViewModelTests: CoreTestCase {

    func testProperties() {
        let course = Course.save(.make(), in: databaseClient)
        let testee = StudentViewCellViewModel(course: course)

        XCTAssertEqual(testee.iconImage, .userLine)
        XCTAssertEqual(testee.label, String(localized: "Student View", bundle: .core))
        XCTAssertEqual(testee.subtitle, String(localized: "Opens in Degrees edX", bundle: .core))
        XCTAssertEqual(testee.accessoryIconType, .externalLink)
        XCTAssertEqual(testee.tabID, "student_view")
    }

    func testErrorOnStudentViewInitialiation() {
        api.mock(GetStudentViewStudent(courseID: "1"), value: nil, response: nil, error: NSError.instructureError("Oops"))
        let course = Course.save(.make(), in: databaseClient)
        let testee = StudentViewCellViewModel(course: course)

        XCTAssertFalse(testee.showGenericError)
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))
        XCTAssertTrue(testee.showGenericError)
    }
}
