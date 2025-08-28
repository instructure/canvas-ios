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

import Foundation
import XCTest

extension CalendarHelper {

    public struct SampleEvents {
        public var yesterdays: DSCalendarEvent?
        public var todays: DSCalendarEvent?
        public var tomorrows: DSCalendarEvent?
        public var recurring: DSCalendarEvent?
        public var nextYears: DSCalendarEvent?
    }

    public enum EventType: String {
        case yesterdays
        case todays
        case tomorrows
        case recurring
        case nextYears
    }

    public static func createSampleCalendarEvents(course: DSCourse, eventTypes: [EventType]) -> SampleEvents {
        var result = SampleEvents()
        if eventTypes.contains(.yesterdays) {
            result.yesterdays = createCalendarEvent(
                course: course,
                title: "Yesterdays Event",
                startDate: Date.now.addDays(-1),
                endDate: Date.now.addDays(-1).addMinutes(30)
            )
        }
        if eventTypes.contains(.todays) {
            result.todays = createCalendarEvent(
                course: course,
                title: "Todays Event",
                startDate: Date.now,
                endDate: Date.now.addMinutes(30)
            )
        }
        if eventTypes.contains(.tomorrows) {
            result.tomorrows = createCalendarEvent(
                course: course,
                title: "Tomorrows Event",
                startDate: Date.now.addDays(1),
                endDate: Date.now.addDays(1).addMinutes(30)
            )
        }
        if eventTypes.contains(.recurring) {
            result.recurring = createCalendarEvent(
                course: course,
                title: "Recurring Event",
                startDate: Date.now,
                endDate: Date.now.addDays(70),
                allDay: true,
                weekly: true
            )
        }
        if eventTypes.contains(.nextYears) {
            result.nextYears = createCalendarEvent(
                course: course,
                title: "Next Years Event",
                startDate: Date.now.addYears(1),
                endDate: Date.now.addYears(1).addMinutes(30),
                allDay: true
            )
        }
        return result
    }

    @discardableResult
    public static func createCalendarEvent(
        course: DSCourse,
        title: String = "Sample Calendar Event",
        description: String = "Be there or be square!",
        startDate: Date = Date.now,
        endDate: Date? = nil,
        locationName: String = "Best Location",
        locationAddress: String = "Right there under that old chestnut tree",
        allDay: Bool? = nil,
        rRule: String? = nil,
        blackoutDate: Bool? = nil,
        weekly: Bool = false
    ) -> DSCalendarEvent {
        let duplicate = weekly ? CreateDSCalendarEventRequest.DSDuplicate(count: 2, frequency: .weekly) : nil
        let calendarEvent = CreateDSCalendarEventRequest.RequestedDSCalendarEvent(
            courseId: course.id,
            title: title,
            description: description,
            start_at: startDate,
            end_at: endDate,
            location_name: locationName,
            location_address: locationAddress,
            all_day: allDay,
            rrule: rRule,
            blackout_date: blackoutDate,
            duplicate: duplicate
        )
        let requestBody = CreateDSCalendarEventRequest.Body(calendar_event: calendarEvent)
        return seeder.createCalendarEvent(requestBody: requestBody)
    }

    @discardableResult
    public static func createAssignmentWithDueDate(
        course: DSCourse,
        dueDate: Date = Date.now
    ) -> DSAssignment {
        AssignmentsHelper.createAssignment(
            course: course,
            dueDate: dueDate
        )
    }

    @discardableResult
    public static func createCalendarToDo(
        course: DSCourse,
        title: String = "Sample Calendar ToDo Item in Course calendar",
        details: String = "Don't forget to remember!",
        todoDate: Date = Date.now
    ) -> DSPlannerNote {
        let contextCode = "course_\(course.id)"

        return seeder.createPlannerNote(requestBody: .init(
            title: title,
            details: details,
            todoDate: todoDate,
            contextCode: contextCode,
            courseId: course.id,
            userId: nil
        ))
    }

    @discardableResult
    public static func createCalendarToDo(
        user: DSUser,
        title: String = "Sample Calendar ToDo Item in User calendar",
        details: String = "Don't forget to remember!",
        todoDate: Date = Date.now
    ) -> DSPlannerNote {
        let contextCode = "user_\(user.id)"

        return seeder.createPlannerNote(requestBody: .init(
            title: title,
            details: details,
            todoDate: todoDate,
            contextCode: contextCode,
            courseId: nil,
            userId: user.id
        ))
    }
}
