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

public class SyllabusHelper: BaseHelper {
    // MARK: UI Elements
    public static var syllabusTab: Element { app.find(id: "Syllabus.syllabusMenuItem") }
    public static var summaryTab: Element { app.find(id: "Syllabus.assignmentsMenuItem") }
    public static var syllabusBody: Element { app.find(id: "syllabusBody").rawElement.find(type: .staticText) }

    public static func summaryAssignmentCell(assignment: DSAssignment) -> Element {
        return app.find(id: "itemCell.assignment_\(assignment.id)")
    }

    public static func summaryAssignmentTitle(assignment: DSAssignment) -> Element {
        return summaryAssignmentCell(assignment: assignment).rawElement.findAll(type: .staticText)[1]
    }

    public static func summaryCalendarEventCell(calendarEvent: DSCalendarEvent) -> Element {
        return app.find(id: "itemCell.\(calendarEvent.id)")
    }

    public static func summaryCalendarEventTitle(calendarEvent: DSCalendarEvent) -> Element {
        return summaryCalendarEventCell(calendarEvent: calendarEvent).rawElement.findAll(type: .staticText)[1]
    }

    public static func navBar(course: DSCourse) -> Element {
        return app.find(id: "Course Syllabus, \(course.name)")
    }

    public static func navigateToSyllabus(course: DSCourse) {
        DashboardHelper.courseCard(course: course).tap()
        let syllabusItem = CourseDetailsHelper.cell(type: .syllabus)
        syllabusItem.swipeUntilVisible()
        syllabusItem.tap()
    }

    // MARK: DataSeeding
    @discardableResult
    public static func createCourseWithSyllabus() -> DSCourse {
        let syllabusBody = "This is the body of the syllabus"
        var result = seeder.createCourse(name: "DS iOS Course With Syllabus \(Int(Date().timeIntervalSince1970))",
                                         syllabus_body: syllabusBody)
        result.syllabus_body = syllabusBody
        return result
    }
}
