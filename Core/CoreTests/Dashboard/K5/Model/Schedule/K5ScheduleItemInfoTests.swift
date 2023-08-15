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

import SwiftUI
import XCTest
@testable import Core

class K5ScheduleItemInfoTests: CoreTestCase {

    func testSubmittedLabelAvailableOnlyForNonLateSubmissions() {
        let containsSubmittedLabel: ([(text: String, color: Color)]) -> Bool = { labels in
            return labels.contains { $0.text == NSLocalizedString("Submitted", comment: "") }
        }
        XCTAssertTrue(containsSubmittedLabel(APIPlannable.make(submissions: .make(submitted: true, late: false)).k5ScheduleLabels))
        XCTAssertFalse(containsSubmittedLabel(APIPlannable.make(submissions: .make(submitted: true, late: true)).k5ScheduleLabels))
    }

    func testScheduleSubjectName() {
        XCTAssertEqual(APIPlannable.make(plannable_type: "calendar_event").k5ScheduleSubject(courseInfoByCourseIDs: [:]).name, NSLocalizedString("To Do", comment: ""))
        XCTAssertEqual(APIPlannable.make(plannable_type: "other", context_name: nil).k5ScheduleSubject(courseInfoByCourseIDs: [:]).name, NSLocalizedString("To Do", comment: ""))
        XCTAssertEqual(APIPlannable.make(plannable_type: "other", context_name: "testName").k5ScheduleSubject(courseInfoByCourseIDs: [:]).name, "testName")
    }

    func testSheduleSubjectRoute() {
        XCTAssertNil(APIPlannable.make(user_id: ID("testId"), context_type: "User").k5ScheduleSubject(courseInfoByCourseIDs: [:]).route)
        XCTAssertEqual(APIPlannable.make(course_id: ID("testId"), context_type: "Course").k5ScheduleSubject(courseInfoByCourseIDs: [:]).route, URL(string: "courses/testId")!)
    }

    func testHomeroomSubjectRoute() {
        XCTAssertNil(APIPlannable.make(course_id: ID("testId"), context_type: "Course")
            .k5ScheduleSubject(courseInfoByCourseIDs: ["testId": (color: .green, image: nil, isHomeroom: true, shouldHideQuantitativeData: true)]).route)
    }

    func testScheduleSubjectColor() {
        Brand.shared = Brand(buttonPrimaryBackground: nil,
                             buttonPrimaryText: nil,
                             buttonSecondaryBackground: nil,
                             buttonSecondaryText: nil,
                             fontColorDark: nil,
                             headerImageBackground: nil,
                             headerImageUrl: nil,
                             linkColor: nil,
                             navBackground: nil,
                             navBadgeBackground: nil,
                             navBadgeText: nil,
                             navIconFill: nil,
                             navIconFillActive: nil,
                             navTextColor: nil,
                             navTextColorActive: nil,
                             primary: .red)
        XCTAssertEqual(APIPlannable.make(course_id: ID("testID")).k5ScheduleSubject(courseInfoByCourseIDs: ["testID": (color: .green,
                                                                                                                       image: nil,
                                                                                                                       isHomeroom: false,
                                                                                                                       shouldHideQuantitativeData: false), ]).color, .green)
        XCTAssertEqual(UIColor(APIPlannable.make(course_id: ID("testID")).k5ScheduleSubject(courseInfoByCourseIDs: [:]).color).cgColor.components, UIColor.red.cgColor.components)
        let subject = APIPlannable.make(course_id: ID("testID_2")).k5ScheduleSubject(courseInfoByCourseIDs: ["testID": (color: .green,
                                                                                                                        image: nil,
                                                                                                                        isHomeroom: false,
                                                                                                                        shouldHideQuantitativeData: false), ])
        XCTAssertEqual(UIColor(subject.color).cgColor.components, UIColor.red.cgColor.components)
    }

    func testDueText() {
        let allDayTestee = APIPlannable.make(plannable: .init(all_day: true, details: nil, end_at: nil, points_possible: nil, start_at: nil, title: nil))
        XCTAssertEqual(allDayTestee.k5ScheduleDueText, NSLocalizedString("All Day", comment: ""))

        let intervalTestee = APIPlannable.make(plannable: .init(all_day: nil, details: nil, end_at: Date().add(.hour, number: 1), points_possible: nil, start_at: Date(), title: nil))
        XCTAssertTrue(intervalTestee.k5ScheduleDueText.contains(" – "))

        let otherTestee = APIPlannable.make(plannable_type: "other", plannable_date: Date())
        XCTAssertTrue(otherTestee.k5ScheduleDueText.hasPrefix("Due: "))
    }

    func testPoints() {
        let singularTestee = APIPlannable.make(plannable: .init(all_day: nil, details: nil, end_at: nil, points_possible: 1, start_at: nil, title: nil))
        XCTAssertEqual(singularTestee.k5SchedulePoints, "1 pt")

        let pluralTestee = APIPlannable.make(plannable: .init(all_day: nil, details: nil, end_at: nil, points_possible: 2, start_at: nil, title: nil))
        XCTAssertEqual(pluralTestee.k5SchedulePoints, "2 pts")
    }

    func testIcons() {
        XCTAssertEqual(APIPlannable.make(plannable_type: "announcement").k5ScheduleIcon, .announcementLine)
        XCTAssertEqual(APIPlannable.make(plannable_type: "assignment").k5ScheduleIcon, .assignmentLine)
        XCTAssertEqual(APIPlannable.make(plannable_type: "calendar_event").k5ScheduleIcon, .calendarTab)
        XCTAssertEqual(APIPlannable.make(plannable_type: "discussion_topic").k5ScheduleIcon, .discussionLine)
        XCTAssertEqual(APIPlannable.make(plannable_type: "planner_note").k5ScheduleIcon, .noteLine)
        XCTAssertEqual(APIPlannable.make(plannable_type: "unknown").k5ScheduleIcon, .addLine)
    }
}
