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
import Student
import XCTest

class AssignmentRemindersInteractorLiveTests: StudentTestCase {

    func testReminderSectionVisibility() {
        let testee = AssignmentRemindersInteractorLive()
        let assignment: Assignment = databaseClient.insert()
        Clock.mockNow(Date())
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        assignment.dueAt = nil
        testee.assignmentDidUpdate.send(assignment)
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        assignment.dueAt = Clock.now
        testee.assignmentDidUpdate.send(assignment)
        XCTAssertFalse(testee.isRemindersSectionVisible.value)

        assignment.dueAt = Clock.now.addSeconds(1)
        testee.assignmentDidUpdate.send(assignment)
        XCTAssertTrue(testee.isRemindersSectionVisible.value)
    }

    func testNewReminder() {
        let testee = AssignmentRemindersInteractorLive()

        testee.newReminderDidSelect.send(DateComponents(minute: 5))

        XCTAssertEqual(testee.reminders.value.count, 1)
        XCTAssertEqual(testee.reminders.value.first?.title, "5 minutes before")
    }

    func testReminderDeletion() {
        let testee = AssignmentRemindersInteractorLive()
        let reminder = AssignmentReminderItem(title: "5 minutes")
        testee.reminders.send([reminder])

        testee.reminderDidDelete.send(reminder)

        XCTAssertTrue(testee.reminders.value.isEmpty)
    }
}
