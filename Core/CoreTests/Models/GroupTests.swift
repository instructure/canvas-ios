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

import Foundation
import XCTest
@testable import Core

class GroupTests: CoreTestCase {
    func testColorWithNoLinkOrCourse() {
        let a = Group.make()
        _ = Color.make()

        XCTAssertEqual(a.color, .named(.ash))
    }

    func testColor() {
        let a = Group.make()
        _ = Color.make(canvasContextID: a.canvasContextID)

        XCTAssertEqual(a.color, .red)
    }

    func testColorWithCourseID() {
        let a = Group.make(from: .make(course_id: "1"))
        _ = Color.make()

        XCTAssertEqual(a.color, .red)
    }
}
