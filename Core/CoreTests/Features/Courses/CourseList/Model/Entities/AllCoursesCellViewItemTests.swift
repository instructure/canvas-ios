//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import XCTest

class AllCoursesCellViewItemTests: CoreTestCase {
    var testee: AllCoursesCellViewModel.Item!
    var group: AllCoursesGroupItem!

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testCourseProperties() {
        let course = AllCoursesCourseItem.make(roles: "student, teacher", termName: "courseTermName")
        testee = .course(course)

        XCTAssertEqual(testee.id, course.courseId)
        XCTAssertEqual(testee.name, course.name)
        XCTAssertEqual(testee.isFavourite, course.isFavorite)
        XCTAssertEqual(testee.path, "/courses/\(course.courseId)")
        XCTAssertEqual(testee.termName, course.termName)
        XCTAssertEqual(testee.roles, course.roles)
        XCTAssertEqual(testee.isPublished, course.isPublished)
        XCTAssertEqual(testee.isFavoriteButtonVisible, course.isFavoriteButtonVisible)
        XCTAssertEqual(testee.isDetailsAvailable, course.isCourseDetailsAvailable)
    }

    func testGroupProperties() {
        let group = AllCoursesGroupItem.make()
        testee = .group(group)

        XCTAssertEqual(testee.id, group.id)
        XCTAssertEqual(testee.name, group.name)
        XCTAssertEqual(testee.isFavourite, group.isFavorite)
        XCTAssertEqual(testee.path, "/groups/\(group.id)")
        XCTAssertEqual(testee.termName, group.courseTermName)
        XCTAssertEqual(testee.roles, group.courseRoles)
        XCTAssertEqual(testee.isPublished, true)
        XCTAssertEqual(testee.isFavoriteButtonVisible, true)
        XCTAssertEqual(testee.isDetailsAvailable, true)
    }
}
