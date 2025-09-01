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

public class CalendarHelper: BaseHelper {

    private static let dateFormatter = DateFormatter()

    // MARK: - Calendar elements

    public static var navBar: XCUIElement { app.find(id: "Core.PlannerView") }
    public static var todayButton: XCUIElement { app.find(id: "PlannerCalendar.todayButton") }
    public static var addButton: XCUIElement { app.find(id: "PlannerCalendar.addButton") }
    public static var addToDo: XCUIElement { app.find(id: "noteLine", type: .image) }
    public static var addEvent: XCUIElement { app.find(id: "calendarMonthLine", type: .image) }

    public static var yearLabel: XCUIElement { app.find(id: "PlannerCalendar.yearLabel") }
    public static var monthButton: XCUIElement { app.find(id: "PlannerCalendar.monthButton") }
    public static var monthLabel: XCUIElement { app.find(id: "PlannerCalendar.monthButton").find(type: .staticText) }
    public static var filterButton: XCUIElement { app.find(id: "PlannerCalendar.filterButton") }
    public static var firstDayButtonOfView: XCUIElement { app.find(idStartingWith: "PlannerCalendar.dayButton.") }

    public static var noEventsLabel: XCUIElement { app.find(id: "PlannerList.emptyTitle") }

    public static func dayButton(for item: DSCalendarItem) -> XCUIElement {
        dayButtonOfDate(item.date)
    }

    private static func dayButtonOfDate(_ date: Date) -> XCUIElement {
        dateFormatter.dateFormat = "yyyy-M-d"
        let dateString = dateFormatter.string(from: date)
        return app.find(id: "PlannerCalendar.dayButton.\(dateString)")
    }

    // MARK: - Event list elements

    private static func allItemCells() -> [XCUIElement] {
        app.findAll(idStartingWith: "PlannerList.event.")
    }

    public static func itemCell(at index: Int) -> XCUIElement {
        waitUntil { allItemCells().count < index + 1 }
        return allItemCells()[index]
    }

    public static func itemCell(for item: DSCalendarItem) -> XCUIElement {
        app.find(id: "PlannerList.event.\(item.id)")
    }

    public static func itemCell(forTitle title: String) -> XCUIElement {
        for cell in allItemCells() {
            let titleLabel = cell.find(labelContaining: title)
            if titleLabel.exists {
                return cell
            }
        }
        return .notFoundFailure("Calendar Item not found for title: \(title)")
    }

    public static func itemCells(forTitle title: String) -> [XCUIElement] {
        allItemCells()
            .filter { $0.find(labelContaining: title).exists }
    }

    // MARK: - Navigation

    public static func navigateToCalendarTab() {
        XCTContext.runActivity(named: "Navigate to Calentar Tab") { _ in
            let calendarTab = TabBar.calendarTab.waitUntil(.visible)
            XCTAssertTrue(calendarTab.isVisible)

            calendarTab.hit()

            let todayButton = todayButton.waitUntil(.visible)
            XCTAssertTrue(todayButton.isVisible)
        }
    }

    public static func navigateToAddToDoScreen() {
        XCTContext.runActivity(named: "Navigate to Add ToDo Screen") { _ in
            let addButton = addButton.waitUntil(.visible)
            XCTAssertTrue(addButton.isVisible)
            addButton.hit()

            let addToDoButton = addToDo.waitUntil(.visible)
            XCTAssertTrue(addToDoButton.isVisible)
            addToDoButton.hit()

            let cancelButton = EditToDo.cancelButton.waitUntil(.visible)
            XCTAssertTrue(cancelButton.isVisible)
        }
    }

    public static func navigateToItemCell(for item: DSCalendarItem) -> XCUIElement {
        navigateToDate(item.date)
        return itemCell(for: item).waitUntil(.visible)
    }

    public static func navigateToItemCell(for assignment: DSAssignment) -> XCUIElement {
        navigateToItemCell(forTitle: assignment.name, dueAt: assignment.due_at ?? .now)
    }

    public static func navigateToItemCell(forTitle title: String, dueAt: Date) -> XCUIElement {
        navigateToDate(dueAt)
        return itemCell(forTitle: title).waitUntil(.visible)
    }

    private static func navigateToDate(_ date: Date) {
        let dayButtonOfEvent = dayButtonOfDate(date).waitUntil(.visible, timeout: 3)

        if dayButtonOfEvent.isHittable {
            dayButtonOfEvent.hit()
            return
        }

        // Formatting the date
        dateFormatter.dateFormat = "yyyy-MMMM-d"
        let formattedDate = dateFormatter.string(from: date)
        let dateArray = formattedDate.split(separator: "-")

        // Expanding the calendar
        monthButton.hit()

        // Finding the year
        let yearOfEvent = Int(dateArray[0])!
        var yearLabelElement = yearLabel.waitUntil(.visible)
        var yearLabelText = Int(yearLabelElement.label.filter("0123456789".contains))!
        let monthSwipeDirection = yearOfEvent < yearLabelText ? "right" : "left"

        if yearOfEvent != yearLabelText {
            for _ in 1...12*abs(yearOfEvent-yearLabelText) {
                let buttonToSwipe = firstDayButtonOfView.waitUntil(.visible)
                if yearOfEvent < yearLabelText { buttonToSwipe.swipeRight() } else { buttonToSwipe.swipeLeft() }
                yearLabelElement = yearLabel.waitUntil(.visible)
                yearLabelText = Int(yearLabelElement.label.filter("0123456789".contains))!
                if yearOfEvent == yearLabelText { break }
            }
        }

        // Finding the month
        let monthOfEvent = dateArray[1]
        var monthLabelElement = monthLabel.waitUntil(.visible)
        var monthLabelText = monthLabelElement.label

        if monthOfEvent != monthLabelText {
            for _ in 1...24 {
                let buttonToSwipe = firstDayButtonOfView.waitUntil(.visible)
                if monthSwipeDirection == "right" { buttonToSwipe.swipeRight() } else { buttonToSwipe.swipeLeft() }
                monthLabelElement = monthLabel.waitUntil(.visible)
                monthLabelText = monthLabelElement.label
                if monthOfEvent == monthLabelText { break }
            }
        }

        // Finding the day and collapsing the calendar
        dayButtonOfEvent.hit()
        monthButton.hit()
    }
}

extension CalendarHelper {

    // MARK: - Item cell

    public struct ItemCell {
        public static func titleLabel(in cell: XCUIElement) -> XCUIElement {
            cell.findAll(type: .staticText, minimumCount: 1)[0]
        }

        public static func secondLabel(in cell: XCUIElement) -> XCUIElement {
            cell.findAll(type: .staticText, minimumCount: 2)[1]
        }

        public static func thirdLabel(in cell: XCUIElement) -> XCUIElement {
            cell.findAll(type: .staticText, minimumCount: 3)[2]
        }

        public static func fourthLabel(in cell: XCUIElement) -> XCUIElement {
            cell.findAll(type: .staticText, minimumCount: 4)[3]
        }

        public static func formattedDate(for event: DSCalendarEvent) -> String {
            formattedDate(event.start_at)
        }

        public static func formattedDate(_ date: Date) -> String {
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            return dateFormatter.string(from: date)
        }
    }

    // MARK: - Event Details screen

    public struct EventDetails {
        public static func titleLabel(event: DSCalendarEvent) -> XCUIElement {
            return app.find(label: event.title, type: .staticText)
        }

        public static func dateLabel(event: DSCalendarEvent, parent: Bool = false) -> XCUIElement {
            let dateString = parent ? formatDateForDateLabelParent(event: event) : formatDateForDateLabel(event: event)
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
            dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
            let formattedDate = dateFormatter.string(from: event.start_at)
            return formattedDate
        }

        public static func formatDateForDateLabelParent(event: DSCalendarEvent) -> String {
            dateFormatter.dateFormat = "MMM d, yyyy, h:mm"
            let formattedDate = dateFormatter.string(from: event.start_at)
            return formattedDate
        }
    }

    // MARK: - ToDo Details screen

    public struct ToDoDetails {
        public static var kebabButton: XCUIElement { app.find(id: "More") }

        public struct More {
            public static var editButton: XCUIElement { app.find(label: "Edit", type: .button) }
            public static var deleteButton: XCUIElement { app.find(label: "Delete", type: .button) }

            public struct Delete {
                public static var deleteTodoText: XCUIElement { app.find(label: "Delete To Do?", type: .staticText) }
                public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }
                public static var deleteButton: XCUIElement { app.find(label: "Delete", type: .button) }
            }
        }
    }

    // MARK: - Calendar Filter screen

    public struct Filter {
        public static var navBar: XCUIElement { app.find(type: .navigationBar).find(label: "Calendars") }
        public static var doneButton: XCUIElement { app.find(label: "Done", type: .button) }
        public static var calendarsLabel: XCUIElement { app.find(label: "Calendars", type: .staticText) }
        public static var deselectAllButton: XCUIElement { app.find(labelContaining: "Deselect", type: .button) }
        public static func courseCell(course: DSCourse) -> XCUIElement {
            return app.find(label: course.name, type: .switch)
        }
    }

    // MARK: - Add/Edit ToDo screen

    public struct EditToDo {
        public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }
        public static var addButton: XCUIElement { app.find(label: "Add", type: .button) }
        public static var saveButton: XCUIElement { app.find(label: "Save", type: .button) }
        public static var titleInput: XCUIElement { app.find(id: "Calendar.Todo.title") }
        public static var calendarSelector: XCUIElement { app.find(id: "Calendar.Todo.calendar") }

        public static var datePicker: XCUIElement { app.find(id: "Calendar.Todo.datePicker.date") }
        public static var timePicker: XCUIElement { app.find(id: "Calendar.Todo.datePicker.time") }

        public static var detailsInput: XCUIElement { app.find(id: "Calendar.Todo.details") }

        public struct CalendarSelector {
            public static var backButton: XCUIElement { app.find(label: "Back", type: .button) }

            public static func userItem(user: DSUser) -> XCUIElement {
                return app.find(id: "user_\(user.id)")
            }

            public static func courseItem(course: DSCourse) -> XCUIElement {
                return app.find(id: "course_\(course.id)")
            }
        }

        public struct DateSelector {
            public static var picker: XCUIElement { app.find(type: .picker)}
            public static var hourWheel: XCUIElement { picker.waitUntil(.visible).findAll(type: .pickerWheel)[0] }
            public static var minutesWheel: XCUIElement { picker.waitUntil(.visible).findAll(type: .pickerWheel)[1] }
            public static var meridiemWheel: XCUIElement { picker.waitUntil(.visible).findAll(type: .pickerWheel)[2] }
        }
    }
}
