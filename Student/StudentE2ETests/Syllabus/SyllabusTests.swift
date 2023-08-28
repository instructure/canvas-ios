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

import TestsFoundation

class SyllabusTests: E2ETestCase {
    func testSyllabusOfCourse() {
        // MARK: Seed the usual stuff with a course containing a syllabus
        let student = seeder.createUser()
        let course = SyllabusHelper.createCourseWithSyllabus()
        seeder.enrollStudent(student, in: course)

        // MARK: Seed an assignment and a calendar event
        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        let calendarEvent = CalendarHelper.createCalendarEvent(course: course, endDate: Date.now.addMinutes(30))

        // MARK: Get the user logged in, navigate to Syllabus, check "Syllabus" tab
        logInDSUser(student)
        SyllabusHelper.navigateToSyllabus(course: course)

        let navBar = SyllabusHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)

        let syllabusTab = SyllabusHelper.syllabusTab.waitUntil(.visible)
        XCTAssertTrue(syllabusTab.isVisible)

        let summaryTab = SyllabusHelper.summaryTab.waitUntil(.visible)
        XCTAssertTrue(summaryTab.isVisible)

        let syllabusBodyLabel = SyllabusHelper.syllabusBody.waitUntil(.visible)
        XCTAssertTrue(syllabusBodyLabel.isVisible)
        XCTAssertEqual(syllabusBodyLabel.label, course.syllabus_body!)

        summaryTab.hit()

        // MARK: Check "Summary" tab
        let summaryAssignmentItem = SyllabusHelper.summaryAssignmentCell(assignment: assignment)
            .waitUntil(.visible)
        XCTAssertTrue(summaryAssignmentItem.isVisible)

        let summaryAssignmentTitle = SyllabusHelper.summaryAssignmentTitle(assignment: assignment)
            .waitUntil(.visible)
        XCTAssertTrue(summaryAssignmentTitle.isVisible)
        XCTAssertEqual(summaryAssignmentTitle.label, assignment.name)

        let summaryCalendarEventItem = SyllabusHelper.summaryCalendarEventCell(calendarEvent: calendarEvent).waitUntil(.visible)
        XCTAssertTrue(summaryCalendarEventItem.isVisible)

        let summaryCalendarEventTitle = SyllabusHelper.summaryCalendarEventTitle(calendarEvent: calendarEvent)
            .waitUntil(.visible)
        XCTAssertTrue(summaryCalendarEventTitle.isVisible)
        XCTAssertEqual(summaryCalendarEventTitle.label, calendarEvent.title)
    }
}
