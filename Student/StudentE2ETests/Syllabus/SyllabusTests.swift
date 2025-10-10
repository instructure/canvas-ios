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
import XCTest

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
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertVisible(profileButton)

        SyllabusHelper.navigateToSyllabus(course: course)

        let navBar = SyllabusHelper.navBar(course: course).waitUntil(.visible)
        XCTAssertVisible(navBar)

        let syllabusTab = SyllabusHelper.syllabusTab.waitUntil(.visible)
        XCTAssertVisible(syllabusTab)

        let summaryTab = SyllabusHelper.summaryTab.waitUntil(.visible)
        XCTAssertVisible(summaryTab)

        let syllabusBodyLabel = SyllabusHelper.syllabusBody.waitUntil(.visible)
        XCTAssertVisible(syllabusBodyLabel)
        XCTAssertEqual(syllabusBodyLabel.label, course.syllabus_body!)

        // MARK: Check "Summary" tab
        summaryTab.hit()
        let summaryAssignmentItem = SyllabusHelper.summaryAssignmentCell(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(summaryAssignmentItem)

        let summaryAssignmentTitle = SyllabusHelper.summaryAssignmentTitle(assignment: assignment).waitUntil(.visible)
        XCTAssertVisible(summaryAssignmentTitle)
        XCTAssertEqual(summaryAssignmentTitle.label, assignment.name)

        let summaryCalendarEventItem = SyllabusHelper.summaryCalendarEventCell(calendarEvent: calendarEvent).waitUntil(.visible)
        XCTAssertVisible(summaryCalendarEventItem)

        let summaryCalendarEventTitle = SyllabusHelper.summaryCalendarEventTitle(calendarEvent: calendarEvent).waitUntil(.visible)
        XCTAssertVisible(summaryCalendarEventTitle)
        XCTAssertEqual(summaryCalendarEventTitle.label, calendarEvent.title)
    }

    func testCourseSummaryDisabled() {
        // MARK: Seed the usual stuff with a course summary disabled
        let student = seeder.createUser()
        let course = SyllabusHelper.createCourseWithSyllabus()
        seeder.updateCourseSettings(course: course, syllabus_course_summary: false)
        seeder.enrollStudent(student, in: course)

        // MARK: Seed an assignment and a calendar event
        AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        CalendarHelper.createCalendarEvent(course: course, endDate: Date.now.addMinutes(30))

        // MARK: Get the user logged in, navigate to Syllabus, check "Syllabus" tab
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertVisible(courseCard)

        // MARK: Navigate to Syllabus, check if tabs (syllabus, summary) are not visible
        SyllabusHelper.navigateToSyllabus(course: course)
        let navBar = SyllabusHelper.navBar(course: course).waitUntil(.visible)
        let syllabusTab = SyllabusHelper.syllabusTab.waitUntil(.vanish)
        let summaryTab = SyllabusHelper.summaryTab.waitUntil(.vanish)
        XCTAssertVisible(navBar)
        XCTAssertTrue(syllabusTab.isVanished)
        XCTAssertTrue(summaryTab.isVanished)
    }
}
