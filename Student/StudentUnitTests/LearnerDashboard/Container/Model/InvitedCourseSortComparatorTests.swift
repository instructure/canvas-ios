//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class InvitedCourseSortComparatorTests: StudentTestCase {

    private var testee: InvitedCourseSortComparator!

    override func setUp() {
        super.setUp()
        testee = InvitedCourseSortComparator()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testSortsByCreationDateAscending() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: now)!

        let course1 = makeCourse(id: "1", name: "Zebra Course", createdAt: lastWeek)
        let course2 = makeCourse(id: "2", name: "Alpha Course", createdAt: now)
        let course3 = makeCourse(id: "3", name: "Beta Course", createdAt: yesterday)

        let sorted = [course1, course2, course3].sorted(using: testee)

        XCTAssertEqual(sorted[0].id, "1")
        XCTAssertEqual(sorted[1].id, "3")
        XCTAssertEqual(sorted[2].id, "2")
    }

    func testSortsByNameWhenDatesAreEqual() {
        let now = Date()

        let course1 = makeCourse(id: "1", name: "Zebra Course", createdAt: now)
        let course2 = makeCourse(id: "2", name: "Alpha Course", createdAt: now)
        let course3 = makeCourse(id: "3", name: "Beta Course", createdAt: now)

        let sorted = [course1, course2, course3].sorted(using: testee)

        XCTAssertEqual(sorted[0].name, "Alpha Course")
        XCTAssertEqual(sorted[1].name, "Beta Course")
        XCTAssertEqual(sorted[2].name, "Zebra Course")
    }

    func testSortsByNameWhenNoDates() {
        let course1 = makeCourse(id: "1", name: "Zebra Course", createdAt: nil)
        let course2 = makeCourse(id: "2", name: "Alpha Course", createdAt: nil)
        let course3 = makeCourse(id: "3", name: "Beta Course", createdAt: nil)

        let sorted = [course1, course2, course3].sorted(using: testee)

        XCTAssertEqual(sorted[0].name, "Alpha Course")
        XCTAssertEqual(sorted[1].name, "Beta Course")
        XCTAssertEqual(sorted[2].name, "Zebra Course")
    }

    func testDatedCoursesBeforeUndated() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        let course1 = makeCourse(id: "1", name: "Zebra Course", createdAt: nil)
        let course2 = makeCourse(id: "2", name: "Alpha Course", createdAt: now)
        let course3 = makeCourse(id: "3", name: "Mid Course", createdAt: yesterday)
        let course4 = makeCourse(id: "4", name: "Beta Course", createdAt: nil)

        let sorted = [course1, course2, course3, course4].sorted(using: testee)

        XCTAssertEqual(sorted[0].id, "3")
        XCTAssertEqual(sorted[1].id, "2")
        XCTAssertEqual(sorted[2].name, "Beta Course")
        XCTAssertEqual(sorted[3].name, "Zebra Course")
    }

    private func makeCourse(id: String,
                            name: String,
                            createdAt: Date?) -> Course {
        let course: Course = databaseClient.insert()
        course.id = id
        course.name = name

        let enrollment: Enrollment = databaseClient.insert()
        enrollment.id = "enroll_\(id)"
        enrollment.state = .invited
        enrollment.createdAt = createdAt
        enrollment.course = course

        try? databaseClient.save()
        return course
    }
}
