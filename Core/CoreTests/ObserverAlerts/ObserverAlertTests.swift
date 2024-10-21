//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
@testable import Core
import TestsFoundation

class ObserverAlertTests: CoreTestCase {

    private var alert: ObserverAlert!

    override func setUp() {
        super.setUp()
        let alert: ObserverAlert = databaseClient.insert()
        self.alert = alert
    }

    override func tearDown() {
        alert = nil
        super.tearDown()
    }

    func testAlertType() {
        alert.alertTypeRaw = "bogus"
        XCTAssertEqual(alert.alertType, .institutionAnnouncement)

        alert.alertTypeRaw = "course_announcement"
        XCTAssertEqual(alert.alertType, .courseAnnouncement)

        alert.alertType = .assignmentMissing
        XCTAssertEqual(alert.alertTypeRaw, "assignment_missing")
    }

    func testWorkflowState() {
        alert.workflowStateRaw = "bogus"
        XCTAssertEqual(alert.workflowState, .unread)
        XCTAssertEqual(alert.isUnread, true)

        alert.workflowStateRaw = "dismissed"
        XCTAssertEqual(alert.workflowState, .dismissed)
        XCTAssertEqual(alert.isUnread, false)

        alert.workflowState = .read
        XCTAssertEqual(alert.workflowStateRaw, "read")
        XCTAssertEqual(alert.isUnread, false)
    }

    func testLockedForUserDefaultValue() {
        XCTAssertEqual(alert.lockedForUser, false)
    }

    func testLockedForUserAPIMapping() {
        alert.id = "testId"

        ObserverAlert.save(.make(id: "testId", locked_for_user: nil), in: databaseClient)
        XCTAssertEqual(alert.lockedForUser, false)

        ObserverAlert.save(.make(id: "testId", locked_for_user: false), in: databaseClient)
        XCTAssertEqual(alert.lockedForUser, false)

        ObserverAlert.save(.make(id: "testId", locked_for_user: true), in: databaseClient)
        XCTAssertEqual(alert.lockedForUser, true)
    }

    func testCourseID() {
        alert.contextID = "contextID"
        alert.htmlURL = URL(string: "https://test.com/courses/courseID/assignments/1434231")!

        alert.alertType = .courseGradeHigh
        XCTAssertEqual(alert.courseID, "contextID")
        alert.alertType = .courseGradeLow
        XCTAssertEqual(alert.courseID, "contextID")

        alert.alertType = .assignmentMissing
        XCTAssertEqual(alert.courseID, nil)
        alert.alertType = .courseAnnouncement
        XCTAssertEqual(alert.courseID, nil)
        alert.alertType = .institutionAnnouncement
        XCTAssertEqual(alert.courseID, nil)

        alert.alertType = .assignmentGradeHigh
        XCTAssertEqual(alert.courseID, "courseID")
        alert.alertType = .assignmentGradeLow
        XCTAssertEqual(alert.courseID, "courseID")

        // Invalid url scenarios
        alert.alertType = .assignmentGradeLow
        alert.htmlURL = URL(string: "https://test.com/courses")!
        XCTAssertEqual(alert.courseID, nil)
    }
}
