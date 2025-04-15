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

    private enum TestConstants {
        static let courseId = "some courseId"
        static let assignmentId = "some assignmentId"
        static let userId = "some userId"
        static let dateNow = Date.make(year: 2100, month: 1, day: 15)
        static let dueDate = dateNow.addDays(2)
    }

    private var mockNotificationCenter: MockUserNotificationCenter!
    private var context: AssignmentReminderContext!

    override func setUp() {
        super.setUp()
        Clock.mockNow(TestConstants.dateNow)
        mockNotificationCenter = MockUserNotificationCenter()
        context = AssignmentReminderContext(
            courseId: TestConstants.courseId,
            assignmentId: TestConstants.assignmentId,
            userId: TestConstants.userId,
            assignmentName: "test",
            dueDate: TestConstants.dueDate
        )
    }

    override func tearDown() {
        Clock.reset()
        mockNotificationCenter = nil
        context = nil
        super.tearDown()
    }

    func testReminderSectionVisibleWhenDueDateInFuture() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: .distantPast))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now.addSeconds(1)))
        XCTAssertTrue(testee.isRemindersSectionVisible.value)
    }

    // MARK: - Reminder Display

    func testLoadsRemindersForCurrentAssignment() {
        mockNotificationCenter.requests = [
            makeNotification(id: "1", timeText: "1 minute before"),
            makeNotification(id: "42", assignmentId: "another id", timeText: "another time")
        ]
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)

        // WHEN
        testee.contextDidUpdate.send(context)

        // THEN
        waitUntil(shouldFail: true) {
            testee.reminders.value == [.init(id: "1", title: "1 minute before")]
        }
    }

    func testListsRemindersInChronologicalOrder() {
        // mocking the already calculated notification trigger time, so we need to use absolute times, not just deltas
        let tMinus3 = triggerDateComponents(from: TestConstants.dueDate.addMinutes(-3))
        let tMinus2 = triggerDateComponents(from: TestConstants.dueDate.addMinutes(-2))
        let tMinus1 = triggerDateComponents(from: TestConstants.dueDate.addMinutes(-1))
        mockNotificationCenter.requests = [
            makeNotification(id: "1", timeText: "3 minutes before", trigger: tMinus3),
            makeNotification(id: "2", timeText: "1 minute before", trigger: tMinus1),
            makeNotification(id: "3", timeText: "2 minutes before", trigger: tMinus2)
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
        XCTAssertEqual(notification.content.userInfo[Key.courseId.rawValue] as? String, TestConstants.courseId)
        XCTAssertEqual(notification.content.userInfo[Key.assignmentId.rawValue] as? String, TestConstants.assignmentId)
        XCTAssertEqual(notification.content.userInfo[Key.userId.rawValue] as? String, TestConstants.userId)
        XCTAssertEqual(notification.content.userInfo[Key.triggerTimeText.rawValue] as? String, "5 minutes before")
        XCTAssertEqual(notification.content.userInfo[UNNotificationContent.RouteURLKey] as? String, "courses/\(TestConstants.courseId)/assignments/\(TestConstants.assignmentId)")

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
        duplicateReminderSubscription.cancel()
    }

    func testReminderDeletion() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: MockUserNotificationCenter())
        let reminder = AssignmentReminderItem(title: "5 minutes")
        testee.reminders.send([reminder])

        testee.reminderDidDelete.send(reminder)

        XCTAssertTrue(testee.reminders.value.isEmpty)
    }

    // MARK: - Helpers

    private func makeNotification(
        id: String = "",
        courseId: String = TestConstants.courseId,
        assignmentId: String = TestConstants.assignmentId,
        userId: String = TestConstants.userId,
        timeText: String = "",
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

    private func triggerDateComponents(from date: Date) -> DateComponents {
        Cal.currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
    }
}
