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

public class CalendarHelper: BaseHelper {
    static var localTimeZoneAbbreviation: String { return TimeZone.current.abbreviation() ?? "" }
    static var plusMinutes = localTimeZoneAbbreviation == "GMT+2" ? 120 : -360

    // MARK: UI Elements
    public static var navBar: Element { app.find(id: "Core.PlannerView") }
    public static var todayButton: Element { app.find(id: "PlannerCalendar.todayButton") }
    public static var addNoteButton: Element { app.find(id: "PlannerCalendar.addNoteButton") }
    public static var yearLabel: Element { app.find(id: "PlannerCalendar.yearLabel") }
    public static var monthButton: Element { app.find(id: "PlannerCalendar.monthButton") }
    public static var filterButton: Element { app.find(id: "PlannerCalendar.filterButton") }

    public static func dayButton(event: DSCalendarEvent) -> Element {
        let dateString = formatDateForDayButton(event: event)
        return app.find(id: "PlannerCalendar.dayButton.\(dateString)")
    }

    public static func formatDateForDayButton(event: DSCalendarEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: event.start_at)!.addMinutes(plusMinutes)
        dateFormatter.dateFormat = "yyyy-M-d"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    public static func formatDateForDateLabel(event: DSCalendarEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let date = dateFormatter.date(from: event.start_at)!.addMinutes(plusMinutes)
        dateFormatter.dateFormat = "MMM dd, yyyy 'at' h:mm a"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    public static func eventCell(event: DSCalendarEvent) -> Element {
        return app.find(id: "PlannerList.event.\(event.id)")
    }

    public static func titleLabelOfEvent(eventCell: Element) -> Element {
        return eventCell.rawElement.findAll(type: .staticText)[0]
    }

    public static func dateLabelOfEvent(eventCell: Element) -> Element {
        return eventCell.rawElement.findAll(type: .staticText)[1]
    }

    public static func courseLabelOfEvent(eventCell: Element) -> Element {
        return eventCell.rawElement.findAll(type: .staticText)[2]
    }

    struct Details {
        public static func titleLabel(event: DSCalendarEvent) -> Element {
            return app.find(label: event.title, type: .staticText)
        }

        public static func dateLabel(event: DSCalendarEvent) -> Element {
            let dateString = formatDateForDateLabel(event: event)
            return app.find(labelContaining: dateString)
        }

        public static func locationNameLabel(event: DSCalendarEvent) -> Element {
            return app.find(label: event.location_name, type: .staticText)
        }

        public static func locationAddressLabel(event: DSCalendarEvent) -> Element {
            return app.find(label: event.location_address, type: .staticText)
        }

        public static func descriptionLabel(event: DSCalendarEvent) -> Element {
            return app.find(label: event.description, type: .staticText)
        }

        public static func formatDateForDateLabel(event: DSCalendarEvent) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let date = dateFormatter.date(from: event.start_at)!.addMinutes(CalendarHelper.plusMinutes)
            dateFormatter.dateFormat = "MMM dd, yyyy, h:mm"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
    }

    // MARK: DataSeeding
    public static func formatDate(addDays: Int = 0, addHours: Int = 0) -> String {
        let date = Date().addDays(addDays).addMinutes(addHours*60)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }

    public static func createSampleCalendarEvents(course: DSCourse) -> SampleEvents {
        let yesterdays = createCalendarEvent(course: course,
                                             title: "Yesterdays Event",
                                             startDate: formatDate(addDays: -1, addHours: 1),
                                             endDate: formatDate(addDays: -1, addHours: 2))
        let todays = createCalendarEvent(course: course,
                                         title: "Todays Event",
                                         startDate: formatDate(addHours: 1),
                                         endDate: formatDate(addHours: 2))
        let tomorrows = createCalendarEvent(course: course,
                                            title: "Tomorrows Event",
                                            startDate: formatDate(addDays: 1, addHours: 1),
                                            endDate: formatDate(addDays: 1, addHours: 2))
        let recurring = createCalendarEvent(course: course,
                                            title: "Recurring Event",
                                            allDay: true,
                                            rRule: "FREQ=WEEKLY;COUNT=10")
        let blackout = createCalendarEvent(course: course,
                                           title: "Blackout Event",
                                           startDate: formatDate(addDays: 2),
                                           endDate: formatDate(addDays: 2),
                                           allDay: true,
                                           blackoutDate: true)
        return SampleEvents(yesterdays: yesterdays,
                            todays: todays,
                            tomorrows: tomorrows,
                            recurring: recurring,
                            blackout: blackout)
    }

    @discardableResult
    public static func createCalendarEvent(course: DSCourse,
                                           title: String = "Sample Calendar Event",
                                           description: String = "Be there or be square!",
                                           startDate: String? = formatDate(),
                                           endDate: String? = formatDate(addHours: 1),
                                           locationName: String = "Best Location",
                                           locationAddress: String = "Right there under that old chestnut tree",
                                           allDay: Bool? = nil,
                                           rRule: String? = nil,
                                           blackoutDate: Bool? = nil) -> DSCalendarEvent {
        let calendarEvent = CreateDSCalendarEventRequest.RequestedDSCalendarEvent(courseId: course.id,
                                                                                  title: title,
                                                                                  description: description,
                                                                                  start_at: startDate,
                                                                                  end_at: endDate,
                                                                                  location_name: locationName,
                                                                                  location_address: locationAddress,
                                                                                  all_day: allDay,
                                                                                  rrule: rRule,
                                                                                  blackout_date: blackoutDate)
        let requestBody = CreateDSCalendarEventRequest.Body(calendar_event: calendarEvent)
        return seeder.createCalendarEvent(requestBody: requestBody)
    }

    public struct SampleEvents {
        let yesterdays: DSCalendarEvent
        let todays: DSCalendarEvent
        let tomorrows: DSCalendarEvent
        let recurring: DSCalendarEvent
        let blackout: DSCalendarEvent
    }
}
