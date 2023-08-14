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

    static var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
    static var plusMinutes = localTimeZoneAbbreviation == "GMT+2" ? -480 : 480
    static var plusMinutesUI = localTimeZoneAbbreviation == "GMT+2" ? 120 : 480
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
        let result = app.find(id: "PlannerCalendar.dayButton.\(dateString)")

        // MARK: Only for debugging calendar tests on Bitrise (should be removed after)
        let selectedDayButton = app.findAll(idStartingWith: "PlannerCalendar.dayButton.").filter({ $0.isSelected })[0]
        XCTAssertEqual(selectedDayButton.label, result.label)

        return result
    }

    public static func formatDateForDayButton(event: DSCalendarEvent) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: event.start_at)!.addMinutes(plusMinutesUI)
        dateFormatter.dateFormat = "yyyy-M-d"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    public static func formatDateForDateLabel(event: DSCalendarEvent) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: event.start_at)!.addMinutes(plusMinutesUI)
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: date)
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
        // Formatting the date
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: event.start_at)!.addMinutes(plusMinutesUI)
        dateFormatter.dateFormat = "yyyy-MMMM-d"
        let formattedDate = dateFormatter.string(from: date)
        let dateArray = formattedDate.split(separator: "-")

        if !dayButton(event: event).isVisible {
            monthButton.hit()
        }

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
        let dayButtonElement = dayButton(event: event).waitUntil(.visible)
        dayButtonElement.hit()
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
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = dateFormatter.date(from: event.start_at)!.addMinutes(CalendarHelper.plusMinutesUI)
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let formattedDate = dateFormatter.string(from: date)
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
    public static func currentDateString() -> String {
        let date = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    public static func formatDate(addYears: Int = 0, addDays: Int = 0, addHours: Int = 0, addMinutes: Int = 0) -> String {
        let date = Date().addYears(addYears).addDays(addDays).addMinutes(addHours*60).addMinutes(addMinutes).addMinutes(plusMinutes)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    public static func createSampleCalendarEvents(course: DSCourse, eventTypes: [EventType]) -> SampleEvents {
        var result = SampleEvents()
        if eventTypes.contains(.yesterdays) {
            result.yesterdays = createCalendarEvent(
                course: course,
                title: "Yesterdays Event",
                startDate: formatDate(addDays: -1, addHours: -1),
                endDate: formatDate(addDays: -1, addHours: 2))
        }
        if eventTypes.contains(.todays) {
            result.todays = createCalendarEvent(
                course: course,
                title: "Todays Event",
                startDate: formatDate(addHours: -1),
                endDate: formatDate(addHours: 2))
        }
        if eventTypes.contains(.tomorrows) {
            result.tomorrows = createCalendarEvent(
                course: course,
                title: "Tomorrows Event",
                startDate: formatDate(addDays: 1, addHours: -1),
                endDate: formatDate(addDays: 1, addHours: 2))
        }
        if eventTypes.contains(.recurring) {
            result.recurring = createCalendarEvent(
                course: course,
                title: "Recurring Event",
                startDate: formatDate(),
                endDate: formatDate(addDays: 70),
                allDay: true,
                weekly: true)
        }
        if eventTypes.contains(.nextYears) {
            result.nextYears = createCalendarEvent(
                course: course,
                title: "Next Years Event",
                startDate: formatDate(addYears: 1, addHours: -1),
                endDate: formatDate(addYears: 1, addHours: 2),
                allDay: true)
        }
        return result
    }

    @discardableResult
    public static func createCalendarEvent(
            course: DSCourse,
            title: String = "Sample Calendar Event",
            description: String = "Be there or be square!",
            startDate: String = formatDate(),
            endDate: String? = nil,
            locationName: String = "Best Location",
            locationAddress: String = "Right there under that old chestnut tree",
            allDay: Bool? = nil,
            rRule: String? = nil,
            blackoutDate: Bool? = nil,
            weekly: Bool = false) -> DSCalendarEvent {
        let now = currentDateString()
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
        let result = seeder.createCalendarEvent(requestBody: requestBody)
        XCTAssertEqual(now, result.start_at)
        return result
    }
}
