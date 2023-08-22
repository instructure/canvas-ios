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

public class CalendarHelper: BaseHelper {
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

    // MARK: Timezone-related stuff
    static let dateFormatter = DateFormatter()

    // MARK: UI Elements
    public static var navBar: XCUIElement { app.find(id: "Core.PlannerView") }
    public static var todayButton: XCUIElement { app.find(id: "PlannerCalendar.todayButton") }
    public static var addNoteButton: XCUIElement { app.find(id: "PlannerCalendar.addNoteButton") }
    public static var yearLabel: XCUIElement { app.find(id: "PlannerCalendar.yearLabel") }
    public static var monthButton: XCUIElement { app.find(id: "PlannerCalendar.monthButton") }
    public static var monthLabel: XCUIElement { app.find(id: "PlannerCalendar.monthButton").find(type: .staticText) }
    public static var filterButton: XCUIElement { app.find(id: "PlannerCalendar.filterButton") }

    public static func dayButton(event: DSCalendarEvent) -> XCUIElement {
        let dateString = formatDateForDayButton(event: event)
        return app.find(id: "PlannerCalendar.dayButton.\(dateString)")
    }

    public static func formatDateForDayButton(event: DSCalendarEvent) -> String {
        dateFormatter.dateFormat = "yyyy-M-d"
        let formattedDate = dateFormatter.string(from: event.start_at)
        return formattedDate
    }

    public static func formatDateForDateLabel(event: DSCalendarEvent) -> String {
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: event.start_at)
        return formattedDate
    }

    public static func eventCell(event: DSCalendarEvent) -> XCUIElement {
        return app.find(id: "PlannerList.event.\(event.id)")
    }

    public static func titleLabelOfEvent(eventCell: XCUIElement) -> XCUIElement {
        return eventCell.findAll(type: .staticText, minimumCount: 1)[0]
    }

    public static func dateLabelOfEvent(eventCell: XCUIElement) -> XCUIElement {
        return eventCell.findAll(type: .staticText, minimumCount: 2)[1]
    }

    public static func courseLabelOfEvent(eventCell: XCUIElement) -> XCUIElement {
        return eventCell.findAll(type: .staticText, minimumCount: 3)[2]
    }

    public static func navigateToEvent(event: DSCalendarEvent) -> XCUIElement {
        let dayButtonOfEvent = dayButton(event: event).waitUntil(.visible, timeout: 3)
        if dayButtonOfEvent.isHittable {
            dayButtonOfEvent.hit()
            return eventCell(event: event).waitUntil(.visible)
        }

        // Formatting the date
        dateFormatter.dateFormat = "yyyy-MMMM-d"
        let formattedDate = dateFormatter.string(from: event.start_at)
        let dateArray = formattedDate.split(separator: "-")

        monthButton.hit()

        // Finding the year
        let yearOfEvent = Int(dateArray[0])!
        var yearLabelElement = yearLabel.waitUntil(.visible)
        var yearLabelText = Int(yearLabelElement.label)!
        let monthSwipeDirection = yearOfEvent < yearLabelText ? "right" : "left"

        if yearOfEvent != yearLabelText {
            for _ in 1...12*abs(yearOfEvent-yearLabelText) {
                if yearOfEvent < yearLabelText { app.swipeRight() } else { app.swipeLeft() }
                yearLabelElement = yearLabel.waitUntil(.visible)
                yearLabelText = Int(yearLabelElement.label)!
                if yearOfEvent == yearLabelText { break }
            }
        }

        // Finding the month
        let monthOfEvent = dateArray[1]
        var monthLabelElement = monthLabel.waitUntil(.visible)
        var monthLabelText = monthLabelElement.label

        if monthOfEvent != monthLabelText {
            for _ in 1...12 {
                if monthSwipeDirection == "right" { app.swipeRight() } else { app.swipeLeft() }
                monthLabelElement = monthLabel.waitUntil(.visible)
                monthLabelText = monthLabelElement.label
                if monthOfEvent == monthLabelText { break }
            }
        }

        // Finding the day and then the event cell
        dayButtonOfEvent.hit()
        monthButton.hit()
        return eventCell(event: event).waitUntil(.visible)
    }

    public struct Details {
        public static func titleLabel(event: DSCalendarEvent) -> XCUIElement {
            return app.find(label: event.title, type: .staticText)
        }

        public static func dateLabel(event: DSCalendarEvent) -> XCUIElement {
            let dateString = formatDateForDateLabel(event: event)
            return app.find(labelContaining: dateString)
        }

        public static func locationNameLabel(event: DSCalendarEvent) -> XCUIElement {
            return app.find(label: event.location_name, type: .staticText)
        }

        public static func locationAddressLabel(event: DSCalendarEvent) -> XCUIElement {
            return app.find(label: event.location_address, type: .staticText)
        }

        public static func descriptionLabel(event: DSCalendarEvent) -> XCUIElement {
            return app.find(label: event.description, type: .staticText)
        }

        public static func formatDateForDateLabel(event: DSCalendarEvent) -> String {
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let formattedDate = dateFormatter.string(from: event.start_at)
            return formattedDate
        }
    }

    public struct Filter {
        public static var navBar: XCUIElement { app.find(id: "Calendars") }
        public static var doneButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static func courseCell(course: DSCourse) -> XCUIElement {
            return app.find(label: course.name, type: .cell)
        }

    }

    // MARK: DataSeeding
    public static func createSampleCalendarEvents(course: DSCourse, eventTypes: [EventType]) -> SampleEvents {
        var result = SampleEvents()
        if eventTypes.contains(.yesterdays) {
            result.yesterdays = createCalendarEvent(
                course: course,
                title: "Yesterdays Event",
                startDate: Date.now.addDays(-1),
                endDate: Date.now.addDays(-1).addMinutes(30))
        }
        if eventTypes.contains(.todays) {
            result.todays = createCalendarEvent(
                course: course,
                title: "Todays Event",
                startDate: Date.now,
                endDate: Date.now.addMinutes(30))
        }
        if eventTypes.contains(.tomorrows) {
            result.tomorrows = createCalendarEvent(
                course: course,
                title: "Tomorrows Event",
                startDate: Date.now.addDays(1),
                endDate: Date.now.addDays(1).addMinutes(30))
        }
        if eventTypes.contains(.recurring) {
            result.recurring = createCalendarEvent(
                course: course,
                title: "Recurring Event",
                startDate: Date.now,
                endDate: Date.now.addDays(70),
                allDay: true,
                weekly: true)
        }
        if eventTypes.contains(.nextYears) {
            result.nextYears = createCalendarEvent(
                course: course,
                title: "Next Years Event",
                startDate: Date.now.addYears(1),
                endDate: Date.now.addYears(1).addMinutes(30),
                allDay: true)
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
            weekly: Bool = false) -> DSCalendarEvent {
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
                duplicate: duplicate)
        let requestBody = CreateDSCalendarEventRequest.Body(calendar_event: calendarEvent)
        return seeder.createCalendarEvent(requestBody: requestBody)
    }
}
