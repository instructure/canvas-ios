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

class ContextTests: XCTestCase {
    func testTypePathComponent() {
        XCTAssertEqual(ContextType.account.pathComponent, "accounts")
        XCTAssertEqual(ContextType.course.pathComponent, "courses")
        XCTAssertEqual(ContextType.group.pathComponent, "groups")
        XCTAssertEqual(ContextType.user.pathComponent, "users")
        XCTAssertEqual(ContextType.section.pathComponent, "sections")
    }

    func testCanvasContextID() {
        XCTAssertEqual(ContextModel(.account, id: "1").canvasContextID, "account_1")
        XCTAssertEqual(ContextModel(.course, id: "2").canvasContextID, "course_2")
        XCTAssertEqual(ContextModel(.group, id: "3").canvasContextID, "group_3")
        XCTAssertEqual(ContextModel(.user, id: "4").canvasContextID, "user_4")
        XCTAssertEqual(ContextModel(.section, id: "5").canvasContextID, "section_5")
    }

    func testPathComponent() {
        XCTAssertEqual(ContextModel(.account, id: "1").pathComponent, "accounts/1")
        XCTAssertEqual(ContextModel(.course, id: "2").pathComponent, "courses/2")
        XCTAssertEqual(ContextModel(.group, id: "3").pathComponent, "groups/3")
        XCTAssertEqual(ContextModel(.user, id: "4").pathComponent, "users/4")
        XCTAssertEqual(ContextModel(.section, id: "5").pathComponent, "sections/5")
    }
}
