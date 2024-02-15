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
                                                    dueDate: Date().addDays(1))

    override func setUp() {
        super.setUp()
        mockNotificationCenter = MockUserNotificationCenter()
    }

    func testReminderSectionVisibleWhenDueDateInFuture() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)
        Clock.mockNow(Date())
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: nil))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now))
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        testee.contextDidUpdate.send(.init(courseId: "", assignmentId: "", userId: "", assignmentName: "", dueDate: Clock.now.addSeconds(1)))
        XCTAssertTrue(testee.isRemindersSectionVisible.value)
    }

    // MARK: - Reminder Display

    func testLoadsRemindersForCurrentAssignment() {
        mockNotificationCenter.requests = [
            .make(),
            UNNotificationRequest.make(id: "11", assignmentId: "22"),
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
        mockNotificationCenter.requests = [
            .make(id: "1", timeText: "3 minutes before", timeUntilFire: 60),
            .make(id: "2", timeText: "1 minute before", timeUntilFire: 180),
            .make(id: "3", timeText: "2 minutes before", timeUntilFire: 120),
        ]
        let testee = AssignmentRemindersInteractorLive(notificationCenter: mockNotificationCenter)

        // WHEN
        testee.contextDidUpdate.send(context)

        // THEN
        waitUntil(shouldFail: true) {
            testee.reminders.value == [
                .init(id: "2", title: "1 minute before"),
                .init(id: "3", title: "2 minutes before"),
                .init(id: "1", title: "3 minutes before"),
            ]
        }
    }

    // MARK: - Reminder Creation

    func testNewReminder() {
        let testee = AssignmentRemindersInteractorLive(notificationCenter: MockUserNotificationCenter())

        testee.newReminderDidSelect.send(DateComponents(minute: 5))

        XCTAssertEqual(testee.reminders.value.count, 1)
        XCTAssertEqual(testee.reminders.value.first?.title, "5 minutes before")
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
        timeUntilFire: TimeInterval = 60
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.userInfo = [
            UNNotificationContent.AssignmentReminderKeys.courseId.rawValue: courseId,
            UNNotificationContent.AssignmentReminderKeys.assignmentId.rawValue: assignmentId,
            UNNotificationContent.AssignmentReminderKeys.userId.rawValue: userId,
            UNNotificationContent.AssignmentReminderKeys.triggerTimeText.rawValue: timeText,
        ]
        return UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: timeUntilFire, repeats: false))
    }
}
