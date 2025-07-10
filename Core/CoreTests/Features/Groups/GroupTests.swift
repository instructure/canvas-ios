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

import Foundation
import XCTest
@testable import Core

class GroupTests: CoreTestCase {
    func testColorWithNoLinkOrCourse() {
        XCTAssertEqual(Group.make().color, .textDark)
    }

    func testColor() {
        ContextColor.make(canvasContextID: "course_1", color: .blue)
        ContextColor.make(canvasContextID: "group_1", color: .red)
        let group = Group.make(from: .make(id: "1", course_id: "1"))
        XCTAssertEqual(group.color.hexString, CourseColorsInteractorLive().courseColorFromAPIColor(.red).hexString)
    }

    func testColorWithCourseID() {
        ContextColor.make(canvasContextID: "course_1", color: .red)
        let group = Group.make(from: .make(course_id: "1"))

        XCTAssertEqual(group.color.hexString, CourseColorsInteractorLive().courseColorFromAPIColor(.red).hexString)
    }

    func testIsActive() {
        var group = Group.make(from: .make(course_id: "1"))
        XCTAssertFalse(group.isActive)

        group = Group.make(from: .make(course_id: nil))
        XCTAssertTrue(group.isActive)

        Course.make(from: .make(workflow_state: .available))
        group = Group.save(.make(course_id: "1"), in: databaseClient)
        XCTAssertTrue(group.isActive)

        Course.make(from: .make(end_at: Date.distantPast), in: databaseClient)
        group = Group.save(.make(course_id: "1"), in: databaseClient)
        XCTAssertFalse(group.isActive)

        Course.make(from: .make(workflow_state: .unpublished))
        group = Group.save(.make(course_id: "1"), in: databaseClient)
        XCTAssertFalse(group.isActive)
    }

    func testCourseRelationship() {
        let course = Course.save(.make(id: "course_1"), in: databaseClient)
        let testee = Group.save(.make(course_id: "course_1"), in: databaseClient)
        XCTAssertEqual(testee.course, course)
    }

    func testDisplayName() {
        let testee = Group.save(.make(name: "some name"), in: databaseClient)
        XCTAssertEqual(testee.displayName, "some name")
    }
}
