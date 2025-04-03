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
    typealias Helper = SyllabusHelper
    typealias EditorHelper = Helper.Editor

    func testSyllabusOfCourse() {
        // MARK: Seed the usual stuff with a course containing a syllabus
        let teacher = seeder.createUser()
        let course = Helper.createCourseWithSyllabus()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Seed an assignment and a calendar event
        let assignment = AssignmentsHelper.createAssignment(course: course, dueDate: Date.now.addMinutes(30))
        let calendarEvent = CalendarHelper.createCalendarEvent(course: course, endDate: Date.now.addMinutes(30))

        // MARK: Get the user logged in, navigate to Syllabus, check "Syllabus" tab
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSyllabus(course: course)
        let navBar = Helper.navBar(course: course).waitUntil(.visible)
        let syllabusTab = Helper.syllabusTab.waitUntil(.visible)
        let summaryTab = Helper.summaryTab.waitUntil(.visible)
        let syllabusBodyLabel = Helper.syllabusBody.waitUntil(.visible)
        XCTAssertTrue(navBar.isVisible)
        XCTAssertTrue(syllabusTab.isVisible)
        XCTAssertTrue(summaryTab.isVisible)
        XCTAssertTrue(syllabusBodyLabel.isVisible)
        XCTAssertEqual(syllabusBodyLabel.label, course.syllabus_body!)

        // MARK: Check "Summary" tab
        summaryTab.hit()
        let summaryAssignmentItem = Helper.summaryAssignmentCell(assignment: assignment).waitUntil(.visible)
        let summaryAssignmentTitle = Helper.summaryAssignmentTitle(assignment: assignment).waitUntil(.visible)
        let summaryCalendarEventItem = Helper.summaryCalendarEventCell(calendarEvent: calendarEvent).waitUntil(.visible)
        let summaryCalendarEventTitle = Helper.summaryCalendarEventTitle(calendarEvent: calendarEvent).waitUntil(.visible)
        XCTAssertTrue(summaryAssignmentItem.isVisible)
        XCTAssertTrue(summaryAssignmentTitle.isVisible)
        XCTAssertEqual(summaryAssignmentTitle.label, assignment.name)
        XCTAssertTrue(summaryCalendarEventItem.isVisible)
        XCTAssertTrue(summaryCalendarEventTitle.isVisible)
        XCTAssertEqual(summaryCalendarEventTitle.label, calendarEvent.title)
    }

    func testSyllabusEditor() {
        // MARK: Seed the usual stuff with a course containing a syllabus
        let teacher = seeder.createUser()
        let course = Helper.createCourseWithSyllabus()
        let newContent = "New content of test syllabus"
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in, navigate to Syllabus
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        Helper.navigateToSyllabus(course: course)
        let syllabusTab = Helper.syllabusTab.waitUntil(.visible)
        let summaryTab = Helper.summaryTab.waitUntil(.visible)
        let syllabusBodyLabel = Helper.syllabusBody.waitUntil(.visible)
        let editButton = Helper.editButton.waitUntil(.visible)
        XCTAssertTrue(syllabusTab.isVisible)
        XCTAssertTrue(summaryTab.isVisible)
        XCTAssertTrue(syllabusBodyLabel.isVisible)
        XCTAssertTrue(editButton.isVisible)

        // MARK: Check elements of Syllabus Editor
        editButton.hit()
        let cancelButton = EditorHelper.cancel.waitUntil(.visible)
        let doneButton = EditorHelper.done.waitUntil(.visible)
        let contentField = EditorHelper.content.waitUntil(.visible)
        let summaryToggle = EditorHelper.showSummary.waitUntil(.visible)
        XCTAssertTrue(cancelButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(contentField.isVisible)
        XCTAssertTrue(summaryToggle.isVisible)
        XCTAssertEqual(summaryToggle.stringValue, "on")

        // MARK: Edit syllabus
        contentField.cutText()
        contentField.writeText(text: newContent)
        summaryToggle.hit()
        XCTAssertEqual(contentField.stringValue, newContent)
        XCTAssertEqual(summaryToggle.stringValue, "off")

        // MARK: Check if editing was successful
        doneButton.hit()
        XCTAssertTrue(syllabusTab.waitUntil(.vanish).isVanished)
        XCTAssertTrue(summaryTab.waitUntil(.vanish).isVanished)
        XCTAssertTrue(syllabusBodyLabel.waitUntil(.visible).isVisible)
        XCTAssertEqual(syllabusBodyLabel.waitUntil(.label(expected: newContent)).label, newContent)
    }
}
