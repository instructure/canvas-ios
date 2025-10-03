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
import Core

class CalendarTests: E2ETestCase {
    typealias Helper = CalendarHelper
    typealias DetailsHelper = Helper.EventDetails
    typealias FilterHelper = Helper.Filter

    func testCalendarLayout() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let event = Helper.createCalendarEvent(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Check elements of event list
        let navBar = Helper.navBar.waitUntil(.visible)
        XCTAssertVisible(navBar)

        let todayButton = Helper.todayButton.waitUntil(.visible)
        XCTAssertVisible(todayButton)

        let addButton = Helper.addButton.waitUntil(.visible)
        XCTAssertVisible(addButton)

        let eventDateButton = Helper.dayButton(for: event).waitUntil(.visible)
        XCTAssertVisible(eventDateButton)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        let eventItem = Helper.itemCell(for: event).waitUntil(.visible)
        XCTAssertVisible(eventItem)

        let eventTitleLabel = Helper.ItemCell.titleLabel(in: eventItem).waitUntil(.visible)
        XCTAssertVisible(eventTitleLabel)
        XCTAssertEqual(eventTitleLabel.label, event.title)

        let eventDateLabel = Helper.ItemCell.secondLabel(in: eventItem).waitUntil(.visible)
        XCTAssertVisible(eventDateLabel)
        XCTAssertEqual(eventDateLabel.label, Helper.ItemCell.formattedDate(for: event))

        let eventCourseLabel = Helper.ItemCell.thirdLabel(in: eventItem).waitUntil(.visible)
        XCTAssertVisible(eventCourseLabel)
        XCTAssertEqual(eventCourseLabel.label, course.name)
    }

    func testCalendarEventDetails() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let event = Helper.createCalendarEvent(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        let eventDateButton = Helper.dayButton(for: event).waitUntil(.visible)
        XCTAssertVisible(eventDateButton)

        eventDateButton.hit()
        XCTAssertTrue(eventDateButton.waitUntil(.selected).isSelected)

        // MARK: Tap on the event item and check the details
        let eventItem = Helper.itemCell(for: event).waitUntil(.visible)
        XCTAssertVisible(eventItem)

        eventItem.hit()
        let titleLabel = DetailsHelper.titleLabel(event: event).waitUntil(.visible)
        XCTAssertVisible(titleLabel)

        let dateLabel = DetailsHelper.dateLabel(event: event).waitUntil(.visible)
        XCTAssertVisible(dateLabel)

        let locationNameLabel = DetailsHelper.locationNameLabel(event: event).waitUntil(.visible)
        XCTAssertVisible(locationNameLabel)

        let locationAddressLabel = DetailsHelper.locationAddressLabel(event: event).waitUntil(.visible)
        XCTAssertVisible(locationAddressLabel)

        let descriptionLabel = DetailsHelper.descriptionLabel(event: event).waitUntil(.visible)
        XCTAssertVisible(descriptionLabel)
    }

    func testNavigateToEventCells() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let eventTypes: [Helper.EventType] = [.todays, .tomorrows, .yesterdays, .nextYears]
        let events = Helper.createSampleCalendarEvents(course: course, eventTypes: eventTypes)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Navigate to the dates and check the events
        let yesterdaysEventItem = Helper.navigateToItemCell(for: events.yesterdays!)
        XCTAssertVisible(yesterdaysEventItem)

        let todaysEventItem = Helper.navigateToItemCell(for: events.todays!)
        XCTAssertVisible(todaysEventItem)

        let tomorrowsEventItem = Helper.navigateToItemCell(for: events.tomorrows!)
        XCTAssertVisible(tomorrowsEventItem)

        let nextYearEventItem = Helper.navigateToItemCell(for: events.nextYears!)
        XCTAssertVisible(nextYearEventItem)
    }

    func testRecurringEvent() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let events = Helper.createSampleCalendarEvents(course: course, eventTypes: [.recurring])

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Navigate to Recurring event and check recurrency
        let recurringEventItem1 = Helper.navigateToItemCell(for: events.recurring!)
        let recurringEventTitle1 = Helper.ItemCell.titleLabel(in: recurringEventItem1).waitUntil(.visible)
        XCTAssertVisible(recurringEventItem1)
        XCTAssertEqual(recurringEventTitle1.label, events.recurring!.title)

        let recurringEventItem2 = Helper.navigateToItemCell(for: events.recurring!.duplicates![0].calendar_event)
        let recurringEventTitle2 = Helper.ItemCell.titleLabel(in: recurringEventItem2).waitUntil(.visible)
        XCTAssertVisible(recurringEventItem2)
        XCTAssertEqual(recurringEventTitle2.label, events.recurring!.duplicates![0].calendar_event.title)

        let recurringEventItem3 = Helper.navigateToItemCell(for: events.recurring!.duplicates![1].calendar_event)
        let recurringEventTitle3 = Helper.ItemCell.titleLabel(in: recurringEventItem3).waitUntil(.visible)
        XCTAssertVisible(recurringEventItem3)
        XCTAssertEqual(recurringEventTitle3.label, events.recurring!.duplicates![1].calendar_event.title)
    }

    func testEventForAssignment() {
        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        let assignment = Helper.createAssignmentWithDueDate(course: course)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // Navigate to cell and check it
        let cell = Helper.navigateToItemCell(for: assignment)
        XCTAssertVisible(cell)
        let titleLabel = Helper.ItemCell.titleLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(titleLabel.label, assignment.name)
    }

    func testEventForDiscussionCheckpoint() {
        let title = "Sample Assignment"
        let date1 = Date.now
        let date2 = Date.now.addDays(1)

        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()
        Helper.createDiscussionCheckpoints(
            course: course,
            title: title,
            repliesRequired: 3,
            replyToTopicDueDate: date1,
            requiredRepliesDueDate: date2
        )

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // Navigate to Step1 cell and check it
        var cell = Helper.navigateToItemCell(forTitle: title, dueAt: date1)
        XCTAssertVisible(cell)
        var titleLabel = Helper.ItemCell.titleLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(titleLabel.label, title)
        var subtitleLabel = Helper.ItemCell.secondLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(subtitleLabel.label, "Reply to topic")
        var dateLabel = Helper.ItemCell.thirdLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(dateLabel.label, Helper.ItemCell.formattedDate(date1))

        // Navigate to Step2 cell and check it
        cell = Helper.navigateToItemCell(forTitle: title, dueAt: date2)
        XCTAssertVisible(cell)
        titleLabel = Helper.ItemCell.titleLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(titleLabel.label, title)
        subtitleLabel = Helper.ItemCell.secondLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(subtitleLabel.label, "Additional replies (3)")
        dateLabel = Helper.ItemCell.thirdLabel(in: cell).waitUntil(.visible)
        XCTAssertEqual(dateLabel.label, Helper.ItemCell.formattedDate(date2))
    }

    func testCourseFilter() {
        // Seed
        let student = seeder.createUser()
        let courses = seeder.createCourses(count: 2)
        let course1 = courses[0]
        let course2 = courses[1]
        seeder.enrollStudent(student, in: course1)
        seeder.enrollStudent(student, in: course2)

        let event1 = Helper.createCalendarEvent(course: course1)
        let event2 = Helper.createCalendarEvent(course: course2)

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Check events
        var eventItem1 = Helper.navigateToItemCell(for: event1)
        var eventItem2 = Helper.navigateToItemCell(for: event2)
        XCTAssertVisible(eventItem1)
        XCTAssertVisible(eventItem2)

        // MARK: Check course filtering
        let filterButton = Helper.filterButton.waitUntil(.visible)
        XCTAssertVisible(filterButton)

        filterButton.hit()

        let filterNavBar = FilterHelper.navBar.waitUntil(.visible)
        XCTAssertVisible(filterNavBar)

        let doneButton = FilterHelper.doneButton.waitUntil(.visible)
        let calendarsLabel = FilterHelper.calendarsLabel.waitUntil(.visible)
        let deselectAllButton = FilterHelper.deselectAllButton.waitUntil(.visible)
        XCTAssertVisible(doneButton)
        XCTAssertVisible(calendarsLabel)
        XCTAssertVisible(deselectAllButton)

        let courseCell1 = FilterHelper.courseCell(course: course1).waitUntil(.visible)
        XCTAssertVisible(courseCell1)
        XCTAssertEqual(courseCell1.waitUntil(.value(expected: "1")).stringValue, "1")

        let courseCell2 = FilterHelper.courseCell(course: course2).waitUntil(.visible)
        XCTAssertVisible(courseCell2)
        XCTAssertEqual(courseCell2.waitUntil(.value(expected: "1")).stringValue, "1")

        // MARK: Change filter to first course
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "1")
        XCTAssertEqual(courseCell2.stringValue, "0")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.visible)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.vanish)
        XCTAssertVisible(eventItem1)
        XCTAssertTrue(eventItem2.isVanished)

        // MARK: Change filter to second course
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "1"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "0")
        XCTAssertEqual(courseCell2.stringValue, "1")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.vanish, gracePeriod: 3)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.visible, gracePeriod: 3)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertVisible(eventItem2)

        // MARK: Change filter to no course selected
        filterButton.hit()
        courseCell1.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        courseCell2.actionUntilElementCondition(action: .tap, condition: .value(expected: "0"), gracePeriod: 3)
        XCTAssertEqual(courseCell1.stringValue, "0")
        XCTAssertEqual(courseCell2.stringValue, "0")

        doneButton.hit()
        eventItem1 = Helper.itemCell(for: event1).waitUntil(.vanish, gracePeriod: 3)
        eventItem2 = Helper.itemCell(for: event2).waitUntil(.vanish, gracePeriod: 3)
        XCTAssertTrue(eventItem1.isVanished)
        XCTAssertTrue(eventItem2.isVanished)
    }

    // MARK: - Add ToDo

    func testCreateCalendarTodoItemWithCourseSelected() {
        let title = "My dear calendar todo item"
        let description = "Description of my dear calendar todo item."

        // Seed
        let (student, course) = Helper.createStudentEnrolledInCourse()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()
        Helper.navigateToAddToDoScreen()

        // MARK: Check UI elements
        let cancelButton = Helper.EditToDo.cancelButton.waitUntil(.visible)
        let addButton2 = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        let calendarSelector = Helper.EditToDo.calendarSelector.waitUntil(.visible)
        let datePicker = Helper.EditToDo.datePicker.waitUntil(.visible)
        let timePicker = Helper.EditToDo.timePicker.waitUntil(.visible)
        let detailsInput = Helper.EditToDo.detailsInput.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(addButton2)
        XCTAssertVisible(titleInput)
        XCTAssertVisible(calendarSelector)
        XCTAssertVisible(datePicker)
        XCTAssertVisible(timePicker)
        XCTAssertVisible(detailsInput)

        // MARK: Fill the form, tap "Done" button
        titleInput.writeText(text: title)
        calendarSelector.hit()
        let backButton = Helper.EditToDo.CalendarSelector.backButton.waitUntil(.visible)
        let courseItem = Helper.EditToDo.CalendarSelector.courseItem(course: course).waitUntil(.visible)
        XCTAssertVisible(backButton)
        XCTAssertVisible(courseItem)
        XCTAssertTrue(courseItem.isUnselected)

        courseItem.hit()
        XCTAssertTrue(courseItem.waitUntil(.selected).isSelected)

        backButton.hit()
        XCTAssertTrue(datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(timePicker.waitUntil(.visible).isVisible)

        timePicker.hit()
        let hourWheel = Helper.EditToDo.DateSelector.hourWheel.waitUntil(.visible)
        let minutesWheel = Helper.EditToDo.DateSelector.minutesWheel.waitUntil(.visible)
        let meridiemWheel = Helper.EditToDo.DateSelector.meridiemWheel.waitUntil(.visible)
        XCTAssertVisible(hourWheel)
        XCTAssertVisible(minutesWheel)
        XCTAssertVisible(meridiemWheel)

        let hourWheelValue = hourWheel.value! as! String
        let meridiemWheelValue = meridiemWheel.value! as! String
        let hour = Int(hourWheelValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        let newHourValue = String(hour == 12 ? 1 : hour + 1)
        hourWheel.adjust(toPickerWheelValue: newHourValue)
        meridiemWheel.adjust(toPickerWheelValue: meridiemWheelValue)
        let newHourWheelValue = "\(newHourValue) o’clock"
        XCTAssertEqual(hourWheel.waitUntil(.value(expected: newHourWheelValue)).stringValue, newHourWheelValue)
        XCTAssertEqual(meridiemWheel.waitUntil(.value(expected: meridiemWheelValue)).stringValue, meridiemWheelValue)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        titleInput.forceTap()
        XCTAssertTrue(detailsInput.waitUntil(.visible).isVisible)

        detailsInput.writeText(text: description)
        XCTAssertTrue(addButton2.waitUntil(.visible).isVisible)

        // MARK: Check result
        addButton2.hit()
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertVisible(calendarEventItem)
        XCTAssertVisible(titleLabel)
    }

    func testCreateCalendarTodoItemWithoutCourseSelected() {
        let title = "My dear calendar todo item"
        let description = "Description of my dear calendar todo item."

        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()
        Helper.navigateToAddToDoScreen()

        let cancelButton = Helper.EditToDo.cancelButton.waitUntil(.visible)
        let addButton2 = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        let calendarSelector = Helper.EditToDo.calendarSelector.waitUntil(.visible)
        let datePicker = Helper.EditToDo.datePicker.waitUntil(.visible)
        let timePicker = Helper.EditToDo.timePicker.waitUntil(.visible)
        let detailsInput = Helper.EditToDo.detailsInput.waitUntil(.visible)
        XCTAssertVisible(cancelButton)
        XCTAssertVisible(addButton2)
        XCTAssertVisible(titleInput)
        XCTAssertVisible(calendarSelector)
        XCTAssertVisible(datePicker)
        XCTAssertVisible(timePicker)
        XCTAssertVisible(detailsInput)

        // MARK: Fill the form, tap "Done" button
        titleInput.writeText(text: title)
        calendarSelector.hit()
        let backButton = Helper.EditToDo.CalendarSelector.backButton.waitUntil(.visible)
        let userItem = Helper.EditToDo.CalendarSelector.userItem(user: student).waitUntil(.visible)
        XCTAssertVisible(backButton)
        XCTAssertVisible(userItem)
        XCTAssertSelected(userItem)

        backButton.hit()
        XCTAssertTrue(datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(timePicker.waitUntil(.visible).isVisible)

        timePicker.hit()
        let hourWheel = Helper.EditToDo.DateSelector.hourWheel.waitUntil(.visible)
        let minutesWheel = Helper.EditToDo.DateSelector.minutesWheel.waitUntil(.visible)
        let meridiemWheel = Helper.EditToDo.DateSelector.meridiemWheel.waitUntil(.visible)
        XCTAssertVisible(hourWheel)
        XCTAssertVisible(minutesWheel)
        XCTAssertVisible(meridiemWheel)

        let hourWheelValue = hourWheel.value! as! String
        let meridiemWheelValue = meridiemWheel.value! as! String
        let hour = Int(hourWheelValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())!
        let newHourValue = String(hour == 12 ? 1 : hour + 1)
        hourWheel.adjust(toPickerWheelValue: newHourValue)
        meridiemWheel.adjust(toPickerWheelValue: meridiemWheelValue)
        let newHourWheelValue = "\(newHourValue) o’clock"
        XCTAssertEqual(hourWheel.waitUntil(.value(expected: newHourWheelValue)).stringValue, newHourWheelValue)
        XCTAssertEqual(meridiemWheel.waitUntil(.value(expected: meridiemWheelValue)).stringValue, meridiemWheelValue)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        titleInput.forceTap()
        XCTAssertTrue(detailsInput.waitUntil(.visible).isVisible)

        detailsInput.writeText(text: description)
        XCTAssertTrue(addButton2.waitUntil(.visible).isVisible)

        // MARK: Check result
        addButton2.hit()
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertVisible(calendarEventItem)
        XCTAssertVisible(titleLabel)
    }

    // MARK: - Edit ToDo

    func testEditCalendarTodoItem() {
        let title = "My dear calendar todo item"
        let newTitle = "My edited todo item"

        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Create Calendar Todo Item
        Helper.navigateToAddToDoScreen()
        let addButton = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        XCTAssertVisible(addButton)
        XCTAssertVisible(titleInput)
        titleInput.writeText(text: title)
        addButton.hit()

        // MARK: Check result
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        XCTAssertVisible(calendarEventItem)
        let titleLabel = calendarEventItem.find(label: title, type: .staticText).waitUntil(.visible)
        XCTAssertVisible(titleLabel)

        // MARK: Open the item, Tap kebab button, Check UI elements
        calendarEventItem.hit()
        let kebabButton = Helper.ToDoDetails.kebabButton.waitUntil(.visible)
        XCTAssertVisible(kebabButton)

        kebabButton.hit()
        let editButton = Helper.ToDoDetails.More.editButton.waitUntil(.visible)
        let deleteButton = Helper.ToDoDetails.More.deleteButton.waitUntil(.visible)
        XCTAssertVisible(editButton)
        XCTAssertVisible(deleteButton)

        // MARK: Tap Edit button, check UI elements
        editButton.hit()
        let saveButton = Helper.EditToDo.saveButton.waitUntil(.visible)
        XCTAssertVisible(saveButton)
        XCTAssertTrue(saveButton.isDisabled)
        XCTAssertTrue(titleInput.waitUntil(.visible).isVisible)

        XCTAssertTrue(Helper.EditToDo.cancelButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.calendarSelector.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.datePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.timePicker.waitUntil(.visible).isVisible)
        XCTAssertTrue(Helper.EditToDo.detailsInput.waitUntil(.visible).isVisible)

        // MARK: Edit the title, Save
        titleInput.cutText()
        titleInput.writeText(text: newTitle)
        saveButton.waitUntil(.enabled)
        XCTAssertTrue(saveButton.isEnabled)

        saveButton.hit()

        // MARK: Check if title label has changed
        let titleElement = app.find(label: newTitle, type: .staticText).waitUntil(.visible)
        XCTAssertVisible(titleElement)
    }

    // MARK: - Delete ToDo

    func testDeleteCalendarTodo() {
        // Seed
        let student = Helper.createStudentEnrolled()

        // Log in, navigate to entry point
        logInDSUser(student)
        Helper.navigateToCalendarTab()

        // MARK: Create Calendar Todo Item
        Helper.navigateToAddToDoScreen()
        let addButton = Helper.EditToDo.addButton.waitUntil(.visible)
        let titleInput = Helper.EditToDo.titleInput.waitUntil(.visible)
        XCTAssertVisible(addButton)
        XCTAssertVisible(titleInput)
        titleInput.writeText(text: "Something")
        addButton.hit()

        // MARK: Check result
        let calendarEventItem = Helper.itemCell(at: 0).waitUntil(.visible)
        XCTAssertVisible(calendarEventItem)

        // MARK: Open the item, Tap kebab button, Check UI elements
        calendarEventItem.hit()
        let kebabButton = Helper.ToDoDetails.kebabButton.waitUntil(.visible)
        XCTAssertVisible(kebabButton)

        kebabButton.hit()
        let editButton = Helper.ToDoDetails.More.editButton.waitUntil(.visible)
        let deleteButton = Helper.ToDoDetails.More.deleteButton.waitUntil(.visible)
        XCTAssertVisible(editButton)
        XCTAssertVisible(deleteButton)

        // MARK: Tap Delete button, check appearing options
        deleteButton.hit()
        let deleteTodoText = Helper.ToDoDetails.More.Delete.deleteTodoText.waitUntil(.visible)
        let cancelTodoButton = Helper.ToDoDetails.More.Delete.cancelButton.waitUntil(.visible)
        let deleteTodoButton = Helper.ToDoDetails.More.Delete.deleteButton.waitUntil(.visible)
        XCTAssertVisible(deleteTodoText)
        XCTAssertVisible(cancelTodoButton)
        XCTAssertVisible(deleteTodoButton)

        // MARK: Tap Delete button, check result
        deleteTodoButton.hit()
        let noEventsLabel = Helper.noEventsLabel.waitUntil(.visible)
        XCTAssertVisible(noEventsLabel)
    }
}
