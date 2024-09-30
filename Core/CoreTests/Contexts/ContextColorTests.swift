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

import Foundation
@testable import TestsFoundation
@testable import Core
import XCTest

class ContextColorTests: CoreTestCase {

    func testSave() {
        let color1 = UIColor(hexString: "#123")!
        let color2 = UIColor(hexString: "#321")!
        let response = APICustomColors(custom_colors: [
            "course_1": color1.hexString,
            "group_1": color2.hexString
        ])
        let result = ContextColor.save(response, in: databaseClient)
        XCTAssertEqual(result.count, 2)

        let course = result.first { $0.canvasContextID == "course_1" }!
        XCTAssertEqual(
            course.color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(color1).hexString
        )

        let group = result.first { $0.canvasContextID == "group_1" }!
        XCTAssertEqual(
            group.color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(color2).hexString
        )
    }
}
