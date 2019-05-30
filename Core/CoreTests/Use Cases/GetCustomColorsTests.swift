//
// Copyright (C) 2018-present Instructure, Inc.
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
@testable import Core

class GetCustomColorsTests: CoreTestCase {
    let useCase = GetCustomColors()

    func testRequest() {
        XCTAssertEqual(useCase.request.path, "users/self/colors")
    }

    func testScope() {
        let course = Color.make(canvasContextID: "course_1")
        let group = Color.make(canvasContextID: "group_1")
        XCTAssert(useCase.scope.predicate.evaluate(with: course))
        XCTAssert(useCase.scope.predicate.evaluate(with: group))
    }

    func testWrite() {
        let response = APICustomColors(custom_colors: ["course_1": "#fff", "group_2": "#000"])
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let colors: [Color] = databaseClient.fetch()
        XCTAssertEqual(colors.count, 2)
    }
}
