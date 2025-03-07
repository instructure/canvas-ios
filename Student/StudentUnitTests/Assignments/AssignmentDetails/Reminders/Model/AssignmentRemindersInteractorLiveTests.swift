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

import Core
@testable import Student
import TestsFoundation
import XCTest

class AssignmentRemindersInteractorLiveTests: StudentTestCase {
    private var mockNotificationCenter: MockUserNotificationCenter!
    private let context = AssignmentReminderContext(courseId: "1",
                                                    assignmentId: "2",
                                                    userId: "3",
                                                    assignmentName: "test",
                                                    dueDate: Date().addDays(2))

    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockUserNotificationCenter()
    }

    func testReminderSectionVisibleWhenDueDateInFuture() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)
        Clock.mockNow(Date())
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: .distantPast))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now.addSeconds(1)))
        XCTAssertTrue(testee.isRemindersSectionVisible.value)
        Clock.reset()
    }

    // MARK: - Reminder Display

    func testLoadsRemindersForCurrentAssignment() {
        mockNotificationCenter.requests = [
            .make(),
            UNNotificationRequest.make(id: "11", assignmentId: "22")
        ]
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)

        // WHEN
        testee.contextDidUpdate.send(context)

        // THEN
        waitUntil(shouldFail: true) {
            testee.reminders.value == [.init(id: "1", title: "1 minute before")]
        }
    }

    // FIXME: flaky test (at least on CI)
    func testListsRemindersInChronologicalOrder() {
        mockNotificationCenter.requests = [
            .make(id: "1", timeText: "3 minutes before", trigger: .init(minute: 57)),
            .make(id: "2", timeText: "1 minute before", trigger: .init(minute: 59)),
            .make(id: "3", timeText: "2 minutes before", trigger: .init(minute: 58))
        ]
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)

        // WHEN
        testee.contextDidUpdate.send(context)

        // THEN
        waitUntil(
            shouldFail: true,
            failureMessage: "Reminders are not in chronological order: \(testee.reminders.value)"
        ) {
            testee.reminders.value == [
                .init(id: "2", title: "1 minute before"),
                .init(id: "3", title: "2 minutes before"),
                .init(id: "1", title: "3 minutes before")
            ]
        }
    }

    // MARK: - Reminder Creation

    func testNewReminder() {
        let notificationCenter = MockUserNotificationCenter()
        let testee = AssignmentRemindersInteractorLive(notificationCenter: notificationCenter)
        testee.contextDidUpdate.send(context)

        // WHEN
        testee.newReminderDidSelect.send(DateComponents(minute: 5))

        // THEN
        XCTAssertEqual(testee.reminders.value.count, 1)
        guard let reminder = testee.reminders.value.first else {
            return XCTFail()
        }
        XCTAssertEqual(reminder.title, "5 minutes before")

        guard let notification = notificationCenter.requests.first else {
            return XCTFail()
        }
        XCTAssertEqual(notification.identifier, reminder.id)
        XCTAssertEqual(notification.content.title, String(localized: "Due Date Reminder"))
        XCTAssertEqual(notification.content.sound, .default)
        let dueText = "5 minutes"
        XCTAssertEqual(notification.content.body, String(localized: "This assignment is due in \(dueText)") + ": test")
        typealias Key = UNNotificationContent.AssignmentReminderKeys
        XCTAssertEqual(notification.content.userInfo[Key.courseId.rawValue] as? String, "1")
        XCTAssertEqual(notification.content.userInfo[Key.assignmentId.rawValue] as? String, "2")
        XCTAssertEqual(notification.content.userInfo[Key.userId.rawValue] as? String, "3")
        XCTAssertEqual(notification.content.userInfo[Key.triggerTimeText.rawValue] as? String, "5 minutes before")
        XCTAssertEqual(notification.content.userInfo[UNNotificationContent.RouteURLKey] as? String, "courses/1/assignments/2")

        guard let timeTrigger = notification.trigger as? UNCalendarNotificationTrigger else {
            return XCTFail()
        }
        XCTAssertEqual(timeTrigger.nextTriggerDate(), context.dueDate.addMinutes(-5))
    }

    func testRemindersForPastDateNotAllowed() {
        let notificationCenter = MockUserNotificationCenter()
        let testee = AssignmentRemindersInteractorLive(notificationCenter: notificationCenter)
        testee.contextDidUpdate.send(context)
        let newReminderResultReceived = expectation(description: "New reminder result received")
        let subscription = testee
            .newReminderCreationResult
            .sink {
                newReminderResultReceived.fulfill()
                XCTAssertEqual($0.error, .reminderInPast)
            }

        // WHEN
        testee.newReminderDidSelect.send(DateComponents(day: 2, minute: 1))

        // THEN
        waitForExpectations(timeout: 5)
        XCTAssertTrue(notificationCenter.requests.isEmpty)
        subscription.cancel()
    }

    func testErrorOnDuplicateReminders() {
        let notificationCenter = MockUserNotificationCenter()
        let testee = AssignmentRemindersInteractorLive(notificationCenter: notificationCenter)
        testee.contextDidUpdate.send(context)

        // Setup first reminder 1 day before event
        let oneDayReminderSetupCompleted = expectation(description: "oneDayReminderSetupCompleted")
        let oneDayReminderSubscription = testee
            .newReminderCreationResult
            .sink {
                oneDayReminderSetupCompleted.fulfill()
                XCTAssertEqual($0.isSuccess, true)
            }
        testee.newReminderDidSelect.send(DateComponents(day: 1))
        wait(for: [oneDayReminderSetupCompleted], timeout: 5)
        oneDayReminderSubscription.cancel()

        let duplicateReminderResultReceived = expectation(description: "New reminder result received")
        let duplicateReminderSubscription = testee
            .newReminderCreationResult
            .sink {
                duplicateReminderResultReceived.fulfill()
                XCTAssertEqual($0.error, .duplicate)
            }

        // WHEN
        testee.newReminderDidSelect.send(DateComponents(hour: 24))

        // THEN
        wait(for: [duplicateReminderResultReceived], timeout: 5)
        XCTAssertEqual(notificationCenter.requests.count, 1)
        print("\(notificationCenter.requests)")
        duplicateReminderSubscription.cancel()
    }

    func testReminderDeletion() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: MockUserNotificationCenter())
        let reminder = AssignmentReminderItem(title: "5 minutes")
        testee.reminders.send([reminder])

        testee.reminderDidDelete.send(reminder)

        XCTAssertTrue(testee.reminders.value.isEmpty)
    }
}

extension UNNotificationRequest {

    static func make(
        id: String = "1",
        courseId: String = "1",
        assignmentId: String = "2",
        userId: String = "3",
        timeText: String = "1 minute before",
        trigger: DateComponents = .init(minute: 60)
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.userInfo = [
            UNNotificationContent.AssignmentReminderKeys.courseId.rawValue: courseId,
            UNNotificationContent.AssignmentReminderKeys.assignmentId.rawValue: assignmentId,
            UNNotificationContent.AssignmentReminderKeys.userId.rawValue: userId,
            UNNotificationContent.AssignmentReminderKeys.triggerTimeText.rawValue: timeText
        ]
        return UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: false))
    }
}
