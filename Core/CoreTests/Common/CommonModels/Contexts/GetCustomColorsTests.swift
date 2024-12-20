//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

class GetCustomColorsTests: CoreTestCase {
    let useCase = GetCustomColors()

    func testRequest() {
        XCTAssertEqual(useCase.request.path, "users/self/colors")
    }

    func testScope() {
        let course = ContextColor.make(canvasContextID: "course_1")
        let group = ContextColor.make(canvasContextID: "group_1")
        XCTAssert(useCase.scope.predicate.evaluate(with: course))
        XCTAssert(useCase.scope.predicate.evaluate(with: group))
    }

    func testWrite() {
        let response = APICustomColors(custom_colors: ["course_1": "#fff", "group_2": "#000"])
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let colors: [ContextColor] = databaseClient.fetch()
        XCTAssertEqual(colors.count, 2)
    }
}
