//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import SwiftUI
@testable import Core

class K5HomeroomSubjectCardViewModelTests: CoreTestCase {

    func testDefaultCardColor() {
        let testee = K5HomeroomSubjectCardViewModel(courseId: "", imageURL: nil, name: "", color: nil, infoLines: [])

        XCTAssertEqual(testee.color, .textDarkest)
    }

    func testUpparcaseName() {
        let testee = K5HomeroomSubjectCardViewModel(courseId: "", imageURL: nil, name: "math", color: nil, infoLines: [])

        XCTAssertEqual(testee.name, "MATH")
    }

    func testProperties() {
        let testee = K5HomeroomSubjectCardViewModel(courseId: "test", imageURL: nil, name: "math", color: nil, infoLines: [])
        XCTAssertEqual(testee.a11yId, "DashboardCourseCell.test")
        XCTAssertEqual(testee.courseRoute, "/courses/test")
    }

    func testInfoLineFromAnnouncement() {
        let announcement = LatestAnnouncement(context: databaseClient)
        announcement.title = "Test announcement title."
        announcement.message = "Test announcement content."

        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(from: announcement, courseId: "test")

        XCTAssertEqual(testee?.icon, .announcementLine)
        XCTAssertEqual(testee?.text, "Test announcement title.")
        XCTAssertEqual(testee?.route, "/courses/test")
    }

    func testInfoLineFromNoAnnouncements() {
        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(from: nil, courseId: "test")

        XCTAssertNil(testee)
    }

    func testInfoLineFromNoAssignments() {
        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(dueToday: 0, missing: 0, courseId: "test")

        XCTAssertEqual(testee.icon, .k5dueToday)
        XCTAssertEqual(testee.text, "Nothing Due Today")
        XCTAssertEqual(testee.highlightedText, "")
        XCTAssertEqual(testee.route, "/courses/test#schedule")
    }

    func testInfoLineFromDueAssignments() {
        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(dueToday: 3, missing: 0, courseId: "test")

        XCTAssertEqual(testee.icon, .k5dueToday)
        XCTAssertEqual(testee.text, "3 due today")
        XCTAssertEqual(testee.highlightedText, "")
        XCTAssertEqual(testee.route, "/courses/test#schedule")
    }

    func testInfoLineFromMissingAssignments() {
        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(dueToday: 0, missing: 3, courseId: "test")

        XCTAssertEqual(testee.icon, .k5dueToday)
        XCTAssertEqual(testee.text, "")
        XCTAssertEqual(testee.highlightedText, "3 missing")
        XCTAssertEqual(testee.route, "/courses/test#schedule")
    }

    func testInfoLineFromDueAndMissingAssignments() {
        let testee = K5HomeroomSubjectCardViewModel.InfoLine.make(dueToday: 3, missing: 1, courseId: "test")

        XCTAssertEqual(testee.icon, .k5dueToday)
        XCTAssertEqual(testee.text, "3 due today | ")
        XCTAssertEqual(testee.highlightedText, "1 missing")
        XCTAssertEqual(testee.route, "/courses/test#schedule")
    }
}
