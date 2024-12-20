//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class CourseSettingsInteractorTests: CoreTestCase {

    func testFiltersCourseIDsBasedOnSettingsValue() {
        api.mock(GetCourseSettingsRequest(courseID: "1"), value: .make(restrict_quantitative_data: true))
        api.mock(GetCourseSettingsRequest(courseID: "2"), value: .make(restrict_quantitative_data: false))

        let testee = CourseSettingsInteractor().courseIDs(
            where: \.restrictQuantitativeData,
            equals: false,
            fromCourseIDs: ["1", "2", "3"]
        )

        XCTAssertSingleOutputEquals(testee, ["2"])
    }
}
