//
// Copyright (C) 2016-present Instructure, Inc.
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

class RouteTests: XCTestCase {
    func testCourse() {
        XCTAssertEqual(Route.course("7").url.path, "/courses/7")
    }

    func testCourseUser() {
        XCTAssertEqual(Route.course("4", user: "5").url.path, "/courses/4/users/5")
    }

    func testCourseAssignment() {
        XCTAssertEqual(Route.course("4", assignment: "1").url.path, "/courses/4/assignments/1")
    }

    func testGroup() {
        XCTAssertEqual(Route.group("2").url.path, "/groups/2")
    }

    func testQuizzesForCourse() {
        XCTAssertEqual(Route.quizzes(forCourse: "9").url.path, "/courses/9/quizzes")
    }
}
