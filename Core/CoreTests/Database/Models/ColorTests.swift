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

import Foundation
@testable import TestsFoundation
@testable import Core
import XCTest

class ColorTests: CoreTestCase {
    func testSave() {
        let response = APICustomColors(custom_colors: ["course_1": "#000", "group_1": "#fff"])
        let result = Color.save(response, in: databaseClient)
        XCTAssertEqual(result.count, 2)
        let course = result.first { $0.canvasContextID == "course_1" }!
        XCTAssertEqual(course.color.hexString, "#000000")
        let group = result.first { $0.canvasContextID == "group_1" }!
        XCTAssertEqual(group.color.hexString, "#ffffff")
    }

    func testSaveSkipsNonColors() {
        let response = APICustomColors(custom_colors: ["course_1": "#000", "group_1": "not a color"])
        let result = Color.save(response, in: databaseClient)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.canvasContextID, "course_1")
    }
}
