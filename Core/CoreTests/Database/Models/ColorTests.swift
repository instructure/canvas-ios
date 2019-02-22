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
