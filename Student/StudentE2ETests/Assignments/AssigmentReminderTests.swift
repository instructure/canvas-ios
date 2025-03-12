//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

class AssignmentReminderTests: E2ETestCase {
    typealias Helper = AssignmentsHelper
    typealias DetailsHelper = Helper.Details
    typealias ReminderHelper = DetailsHelper.Reminder

    func enableNotifications() {
        // MARK: Enabling notifications for Canvas Student app
        SettingsAppHelper.app.launch()
        let canvasStudentButton = SettingsAppHelper.canvasStudentButton.waitUntil(.visible)
        XCTAssertTrue(canvasStudentButton.isVisible)

        canvasStudentButton.actionUntilElementCondition(action: .swipeUp(.customApp(SettingsAppHelper.app)), condition: .hittable)
        XCTAssertTrue(canvasStudentButton.isHittable)

        canvasStudentButton.hit()
        let notificationsButton = SettingsAppHelper.CanvasStudent.notificationsButton.waitUntil(.visible)
        XCTAssertTrue(notificationsButton.isVisible)

        notificationsButton.hit()
        let notificationToggle = SettingsAppHelper.CanvasStudent.Notifications.notificationsToggle.waitUntil(.visible)
        XCTAssertTrue(notificationToggle.isVisible)

        if notificationToggle.hasValue(value: "0") {
            notificationToggle.hit()
        }
        XCTAssertTrue(notificationToggle.waitUntil(.value(expected: "1")).hasValue(value: "1"))

        app.activate()
    }

    func testAssignmentReminder() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry], dueDate: .now.addMinutes(7))

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.hasLabel(label: assignment.name, strict: false))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)

        let reminderLabel = DetailsHelper.reminder.waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)

        let addReminderButton = DetailsHelper.addReminder.waitUntil(.visible)
        XCTAssertTrue(addReminderButton.isVisible)

        // MARK: Tap "Add reminder" button, check elements
        addReminderButton.hit()
        let fiveMinButton = ReminderHelper.fiveMinButton.waitUntil(.visible)
        let fifteenMinButton = ReminderHelper.fifteenMinButton.waitUntil(.visible)
        let thirtyMinButton = ReminderHelper.thirtyMinButton.waitUntil(.visible)
        let oneHourButton = ReminderHelper.oneHourButton.waitUntil(.visible)
        let oneDayButton = ReminderHelper.oneDayButton.waitUntil(.visible)
        let oneWeekButton = ReminderHelper.oneWeekButton.waitUntil(.visible)
        let customButton = ReminderHelper.customButton.waitUntil(.visible)
        let doneButton = ReminderHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(fiveMinButton.isVisible)
        XCTAssertTrue(fifteenMinButton.isVisible)
        XCTAssertTrue(thirtyMinButton.isVisible)
        XCTAssertTrue(oneHourButton.isVisible)
        XCTAssertTrue(oneDayButton.isVisible)
        XCTAssertTrue(oneWeekButton.isVisible)
        XCTAssertTrue(customButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(doneButton.isDisabled)

        // MARK: Choose "1 Week Before", check warning message
        oneWeekButton.hit()
        doneButton.hit()
        let okButton = ReminderHelper.okButton.waitUntil(.visible)
        let reminderCreationFailed = ReminderHelper.reminderCreationFailed.waitUntil(.visible)
        let chooseFutureTime = ReminderHelper.chooseFutureTime.waitUntil(.visible)
        XCTAssertTrue(okButton.isVisible)
        XCTAssertTrue(reminderCreationFailed.isVisible)
        XCTAssertTrue(chooseFutureTime.isVisible)

        // MARK: Choose "5 Minutes Before", check detail screen
        okButton.hit()
        XCTAssertTrue(fiveMinButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(doneButton.waitUntil(.visible).isVisible)

        fiveMinButton.hit()
        doneButton.hit()
        XCTAssertTrue(reminderLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(label: "5 minutes before", type: .staticText).waitUntil(.visible).isVisible)

        // MARK: Close app, wait for the reminder
        XCUIDevice.shared.press(.home)
        let notificationBanner = ReminderHelper.notificationBanner.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(notificationBanner.isVisible)
        XCTAssertTrue(notificationBanner.hasLabel(label: "This assignment is due in 5 minutes", strict: false))
    }

    func testAssignmentReminderWithCustomDate() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry], dueDate: .now.addMinutes(182))

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.hasLabel(label: assignment.name, strict: false))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)

        let reminderLabel = DetailsHelper.reminder.waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)

        let addReminderButton = DetailsHelper.addReminder.waitUntil(.visible)
        XCTAssertTrue(addReminderButton.isVisible)

        // MARK: Tap "Add reminder" button, check elements
        addReminderButton.hit()
        let fiveMinButton = ReminderHelper.fiveMinButton.waitUntil(.visible)
        let fifteenMinButton = ReminderHelper.fifteenMinButton.waitUntil(.visible)
        let thirtyMinButton = ReminderHelper.thirtyMinButton.waitUntil(.visible)
        let oneHourButton = ReminderHelper.oneHourButton.waitUntil(.visible)
        let oneDayButton = ReminderHelper.oneDayButton.waitUntil(.visible)
        let oneWeekButton = ReminderHelper.oneWeekButton.waitUntil(.visible)
        let customButton = ReminderHelper.customButton.waitUntil(.visible)
        let doneButton = ReminderHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(fiveMinButton.isVisible)
        XCTAssertTrue(fifteenMinButton.isVisible)
        XCTAssertTrue(thirtyMinButton.isVisible)
        XCTAssertTrue(oneHourButton.isVisible)
        XCTAssertTrue(oneDayButton.isVisible)
        XCTAssertTrue(oneWeekButton.isVisible)
        XCTAssertTrue(customButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(doneButton.isDisabled)

        // MARK: Choose "Custom", set it to remind 3 hours before
        customButton.hit()
        let numberPicker = ReminderHelper.numberPickerWheel.waitUntil(.visible)
        let timeUnitPicker = ReminderHelper.timeUnitPickerWheel.waitUntil(.visible)
        XCTAssertTrue(numberPicker.isVisible)
        XCTAssertTrue(timeUnitPicker.isVisible)
        XCTAssertTrue(numberPicker.hasValue(value: "1"))
        XCTAssertTrue(timeUnitPicker.hasValue(value: "Minutes Before"))

        numberPicker.adjust(toPickerWheelValue: "3")
        timeUnitPicker.adjust(toPickerWheelValue: "Hours Before")
        XCTAssertTrue(numberPicker.hasValue(value: "3"))
        XCTAssertTrue(timeUnitPicker.hasValue(value: "Hours Before"))

        doneButton.hit()
        XCTAssertTrue(reminderLabel.waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(label: "3 hours before", type: .staticText).waitUntil(.visible).isVisible)

        // MARK: Close app, wait for the reminder
        XCUIDevice.shared.press(.home)
        let notificationBanner = ReminderHelper.notificationBanner.waitUntil(.visible, timeout: 90)
        XCTAssertTrue(notificationBanner.isVisible)
        XCTAssertTrue(notificationBanner.hasLabel(label: "This assignment is due in 3 hours", strict: false))
    }

    func testRemoveAssignmentReminder() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry], dueDate: .now.addMinutes(10))

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.hasLabel(label: assignment.name, strict: false))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)

        let reminderLabel = DetailsHelper.reminder.waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)

        let addReminderButton = DetailsHelper.addReminder.waitUntil(.visible)
        XCTAssertTrue(addReminderButton.isVisible)

        // MARK: Tap "Add reminder" button, check elements
        addReminderButton.hit()
        let fiveMinButton = ReminderHelper.fiveMinButton.waitUntil(.visible)
        let fifteenMinButton = ReminderHelper.fifteenMinButton.waitUntil(.visible)
        let thirtyMinButton = ReminderHelper.thirtyMinButton.waitUntil(.visible)
        let oneHourButton = ReminderHelper.oneHourButton.waitUntil(.visible)
        let oneDayButton = ReminderHelper.oneDayButton.waitUntil(.visible)
        let oneWeekButton = ReminderHelper.oneWeekButton.waitUntil(.visible)
        let customButton = ReminderHelper.customButton.waitUntil(.visible)
        let doneButton = ReminderHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(fiveMinButton.isVisible)
        XCTAssertTrue(fifteenMinButton.isVisible)
        XCTAssertTrue(thirtyMinButton.isVisible)
        XCTAssertTrue(oneHourButton.isVisible)
        XCTAssertTrue(oneDayButton.isVisible)
        XCTAssertTrue(oneWeekButton.isVisible)
        XCTAssertTrue(customButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(doneButton.isDisabled)

        // MARK: Choose "5 Minutes Before", check detail screen
        XCTAssertTrue(fiveMinButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(doneButton.waitUntil(.visible).isVisible)

        fiveMinButton.hit()
        doneButton.hit()
        reminderLabel.waitUntil(.visible)
        let fiveMinutesBeforeLabel = app.find(label: "5 minutes before", type: .staticText).waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)
        XCTAssertTrue(fiveMinutesBeforeLabel.isVisible)

        // MARK: Tap remove button, check if removal was successful
        let removeReminderButton = DetailsHelper.removeReminder.waitUntil(.visible)
        XCTAssertTrue(removeReminderButton.isVisible)

        removeReminderButton.hit()
        let removalLabel = DetailsHelper.removalLabel.waitUntil(.visible)
        let removalAreYouSureLabel = DetailsHelper.removalAreYouSureLabel.waitUntil(.visible)
        let noButton = DetailsHelper.noButton.waitUntil(.visible)
        let yesButton = DetailsHelper.yesButton.waitUntil(.visible)
        XCTAssertTrue(removalLabel.isVisible)
        XCTAssertTrue(removalAreYouSureLabel.isVisible)
        XCTAssertTrue(noButton.isVisible)
        XCTAssertTrue(yesButton.isVisible)

        yesButton.hit()
        fiveMinutesBeforeLabel.waitUntil(.visible, timeout: 5)
        XCTAssertTrue(fiveMinutesBeforeLabel.isVanished)
    }

    func testDuplicatedAssignmentReminder() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Create an assignment
        let assignment = Helper.createAssignment(course: course, submissionTypes: [.online_text_entry], dueDate: .now.addMinutes(7))

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Assignments and check visibility
        Helper.navigateToAssignments(course: course)
        let assignmentButton = Helper.assignmentButton(assignment: assignment).waitUntil(.visible)
        XCTAssertTrue(assignmentButton.isVisible)
        XCTAssertTrue(assignmentButton.hasLabel(label: assignment.name, strict: false))

        // MARK: Tap on the assignment and check details
        assignmentButton.hit()
        let dueLabel = DetailsHelper.due.waitUntil(.visible)
        XCTAssertTrue(dueLabel.isVisible)

        let reminderLabel = DetailsHelper.reminder.waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)

        let addReminderButton = DetailsHelper.addReminder.waitUntil(.visible)
        XCTAssertTrue(addReminderButton.isVisible)

        // MARK: Tap "Add reminder" button, check elements
        addReminderButton.hit()
        let fiveMinButton = ReminderHelper.fiveMinButton.waitUntil(.visible)
        let fifteenMinButton = ReminderHelper.fifteenMinButton.waitUntil(.visible)
        let thirtyMinButton = ReminderHelper.thirtyMinButton.waitUntil(.visible)
        let oneHourButton = ReminderHelper.oneHourButton.waitUntil(.visible)
        let oneDayButton = ReminderHelper.oneDayButton.waitUntil(.visible)
        let oneWeekButton = ReminderHelper.oneWeekButton.waitUntil(.visible)
        let customButton = ReminderHelper.customButton.waitUntil(.visible)
        let doneButton = ReminderHelper.doneButton.waitUntil(.visible)
        XCTAssertTrue(fiveMinButton.isVisible)
        XCTAssertTrue(fifteenMinButton.isVisible)
        XCTAssertTrue(thirtyMinButton.isVisible)
        XCTAssertTrue(oneHourButton.isVisible)
        XCTAssertTrue(oneDayButton.isVisible)
        XCTAssertTrue(oneWeekButton.isVisible)
        XCTAssertTrue(customButton.isVisible)
        XCTAssertTrue(doneButton.isVisible)
        XCTAssertTrue(doneButton.isDisabled)

        // MARK: Choose "5 Minutes Before", check detail screen
        XCTAssertTrue(fiveMinButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(doneButton.waitUntil(.visible).isVisible)

        fiveMinButton.hit()
        doneButton.hit()
        reminderLabel.waitUntil(.visible)
        let fiveMinutesBeforeLabel = app.find(label: "5 minutes before", type: .staticText).waitUntil(.visible)
        XCTAssertTrue(reminderLabel.isVisible)
        XCTAssertTrue(fiveMinutesBeforeLabel.isVisible)
        XCTAssertTrue(addReminderButton.waitUntil(.visible).isVisible)

        // MARK: Tap "Add reminder" button again, choose custom
        addReminderButton.hit()
        XCTAssertTrue(customButton.waitUntil(.visible).isVisible)

        customButton.hit()
        let numberPicker = ReminderHelper.numberPickerWheel.waitUntil(.visible)
        let timeUnitPicker = ReminderHelper.timeUnitPickerWheel.waitUntil(.visible)
        XCTAssertTrue(numberPicker.isVisible)
        XCTAssertTrue(timeUnitPicker.isVisible)
        XCTAssertTrue(numberPicker.hasValue(value: "1"))
        XCTAssertTrue(timeUnitPicker.hasValue(value: "Minutes Before"))

        // MARK: Set to the same (5 minutes)
        numberPicker.adjust(toPickerWheelValue: "5")
        timeUnitPicker.adjust(toPickerWheelValue: "Minutes Before")
        XCTAssertTrue(numberPicker.hasValue(value: "5"))
        XCTAssertTrue(timeUnitPicker.hasValue(value: "Minutes Before"))

        // MARK: Check warning message
        doneButton.hit()
        let okButton = ReminderHelper.okButton.waitUntil(.visible)
        let reminderCreationFailed = ReminderHelper.reminderCreationFailed.waitUntil(.visible)
        let youHaveAlreadySet = ReminderHelper.youHaveAlreadySet.waitUntil(.visible)
        XCTAssertTrue(okButton.isVisible)
        XCTAssertTrue(reminderCreationFailed.isVisible)
        XCTAssertTrue(youHaveAlreadySet.isVisible)
    }
}
