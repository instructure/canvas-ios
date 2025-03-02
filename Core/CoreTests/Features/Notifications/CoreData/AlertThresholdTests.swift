//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class AlertThresholdTests: CoreTestCase {
    func testTypeName() {
        XCTAssertEqual(AlertThresholdType.assignmentGradeHigh.name, "Assignment grade above")
        XCTAssertEqual(AlertThresholdType.assignmentGradeLow.name, "Assignment grade below")
        XCTAssertEqual(AlertThresholdType.assignmentMissing.name, "Assignment missing")
        XCTAssertEqual(AlertThresholdType.courseAnnouncement.name, "Course announcements")
        XCTAssertEqual(AlertThresholdType.courseGradeHigh.name, "Course grade above")
        XCTAssertEqual(AlertThresholdType.courseGradeLow.name, "Course grade below")
        XCTAssertEqual(AlertThresholdType.institutionAnnouncement.name, "Global announcements")
    }

    func testTypeTitle() {
        XCTAssertEqual(AlertThresholdType.assignmentGradeHigh.title(for: 92), "Assignment Grade Above 92")
        XCTAssertEqual(AlertThresholdType.assignmentGradeLow.title(for: nil), "Assignment Grade Below 0")
        XCTAssertEqual(AlertThresholdType.assignmentMissing.title(for: nil), "Assignment Missing")
        XCTAssertEqual(AlertThresholdType.courseAnnouncement.title(for: 7), "Course Announcement")
        XCTAssertEqual(AlertThresholdType.courseGradeHigh.title(for: 80), "Course Grade Above 80")
        XCTAssertEqual(AlertThresholdType.courseGradeLow.title(for: 30), "Course Grade Below 30")
        XCTAssertEqual(AlertThresholdType.institutionAnnouncement.title(for: nil), "Global Announcement")
    }

    func testIsPercent() {
        XCTAssertEqual(AlertThresholdType.assignmentGradeHigh.isPercent, true)
        XCTAssertEqual(AlertThresholdType.assignmentGradeLow.isPercent, true)
        XCTAssertEqual(AlertThresholdType.assignmentMissing.isPercent, false)
        XCTAssertEqual(AlertThresholdType.courseAnnouncement.isPercent, false)
        XCTAssertEqual(AlertThresholdType.courseGradeHigh.isPercent, true)
        XCTAssertEqual(AlertThresholdType.courseGradeLow.isPercent, true)
        XCTAssertEqual(AlertThresholdType.institutionAnnouncement.isPercent, false)
    }

    func testModel() {
        let a = AlertThreshold(context: databaseClient)
        a.id = "1"
        a.observerID = "1"
        a.studentID = "2"
        a.threshold = 100
        a.type = AlertThresholdType.assignmentMissing

        try? databaseClient.save()
        let alerts: [AlertThreshold] = databaseClient.fetch()
        XCTAssertNotNil(alerts.first)
        XCTAssertEqual(alerts.first?.value, 100)
        XCTAssertEqual(alerts.first?.type, .assignmentMissing)
    }
}
