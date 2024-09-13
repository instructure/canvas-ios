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

import Foundation
import XCTest
@testable import Core

class PlannableTests: CoreTestCase {
    private enum TestConstants {
        static let courseId = "some courseId"
        static let groupId = "some groupId"
        static let userId = "some userId"
        static let plannableId = "some plannableId"
        static let htmlUrl = URL(string: "http://some.address")!
        static let contextName = "some contextName"
        static let plannableTitle = "some plannableTitle"
        static let plannableDetails = "some plannableDetails"
        static let plannableDate = Clock.now
        static let pointsPossible: Double = 42.5
    }

    func testSaveAPIPlannable() {
        let apiPlannable = APIPlannable(
            course_id: ID(TestConstants.courseId),
            group_id: ID(TestConstants.groupId),
            user_id: ID(TestConstants.userId),
            context_type: "Course",
            planner_override: nil,
            plannable_id: ID(TestConstants.plannableId),
            plannable_type: PlannableType.assignment.rawValue,
            html_url: APIURL(rawValue: TestConstants.htmlUrl),
            context_name: TestConstants.contextName,
            plannable: .init(
                details: TestConstants.plannableDetails,
                points_possible: TestConstants.pointsPossible,
                title: TestConstants.plannableTitle
            ),
            plannable_date: TestConstants.plannableDate,
            submissions: nil
        )

        let plannable = Plannable.save(apiPlannable, userID: "another userId", in: databaseClient)

        XCTAssertEqual(plannable.id, TestConstants.plannableId)
        XCTAssertEqual(plannable.plannableType, .assignment)
        XCTAssertEqual(plannable.htmlURL, TestConstants.htmlUrl)
        XCTAssertEqual(plannable.contextName, TestConstants.contextName)
        XCTAssertEqual(plannable.title, TestConstants.plannableTitle)
        XCTAssertEqual(plannable.date, TestConstants.plannableDate)
        XCTAssertEqual(plannable.pointsPossible, TestConstants.pointsPossible)
        XCTAssertEqual(plannable.details, TestConstants.plannableDetails)
        XCTAssertEqual(plannable.context?.courseId, TestConstants.courseId)
        XCTAssertEqual(plannable.userID, "another userId")
    }

    func testSaveAPIPlannerNote() {
        var apiPlannerNote = APIPlannerNote.make(
            id: TestConstants.plannableId,
            title: TestConstants.plannableTitle,
            details: TestConstants.plannableDetails,
            todo_date: TestConstants.plannableDate
        )

        var plannable = Plannable.save(apiPlannerNote, contextName: TestConstants.contextName, in: databaseClient)

        XCTAssertEqual(plannable.id, TestConstants.plannableId)
        XCTAssertEqual(plannable.plannableType, .planner_note)
        XCTAssertEqual(plannable.htmlURL, nil)
        XCTAssertEqual(plannable.contextName, TestConstants.contextName)
        XCTAssertEqual(plannable.title, TestConstants.plannableTitle)
        XCTAssertEqual(plannable.date, TestConstants.plannableDate)
        XCTAssertEqual(plannable.pointsPossible, nil)
        XCTAssertEqual(plannable.details, TestConstants.plannableDetails)

        // with userId and courseId
        apiPlannerNote = APIPlannerNote.make(user_id: TestConstants.userId, course_id: TestConstants.courseId)
        plannable = Plannable.save(apiPlannerNote, contextName: nil, in: databaseClient)
        XCTAssertEqual(plannable.context?.courseId, TestConstants.courseId)
        XCTAssertEqual(plannable.userID, TestConstants.userId)

        // with only userId
        apiPlannerNote = APIPlannerNote.make(user_id: TestConstants.userId, course_id: nil)
        plannable = Plannable.save(apiPlannerNote, contextName: nil, in: databaseClient)
        XCTAssertEqual(plannable.context?.userId, TestConstants.userId)
        XCTAssertEqual(plannable.userID, TestConstants.userId)

        // with only courseId
        apiPlannerNote = APIPlannerNote.make(user_id: nil, course_id: TestConstants.courseId)
        plannable = Plannable.save(apiPlannerNote, contextName: nil, in: databaseClient)
        XCTAssertEqual(plannable.context?.courseId, TestConstants.courseId)
        XCTAssertEqual(plannable.userID, nil)

        // without userId or courseId
        apiPlannerNote = APIPlannerNote.make(user_id: nil, course_id: nil)
        plannable = Plannable.save(apiPlannerNote, contextName: nil, in: databaseClient)
        XCTAssertEqual(plannable.context, nil)
        XCTAssertEqual(plannable.userID, nil)
    }

    func testIcon() {
        var p = Plannable.make(from: .make(plannable_type: "assignment"))
        XCTAssertEqual(p.icon(), UIImage.assignmentLine)

        p = Plannable.make(from: .make(plannable_type: "quiz"))
        XCTAssertEqual(p.icon(), UIImage.quizLine)

        p = Plannable.make(from: .make(plannable_type: "discussion_topic"))
        XCTAssertEqual(p.icon(), UIImage.discussionLine)

        p = Plannable.make(from: .make(plannable_type: "wiki_page"))
        XCTAssertEqual(p.icon(), UIImage.documentLine)

        p = Plannable.make(from: .make(plannable_type: "planner_note"))
        XCTAssertEqual(p.icon(), UIImage.noteLine)

        p = Plannable.make(from: .make(plannable_type: "other"))
        XCTAssertEqual(p.icon(), UIImage.warningLine)

        p = Plannable.make(from: .make(plannable_type: "announcement"))
        XCTAssertEqual(p.icon(), UIImage.announcementLine)

        p = Plannable.make(from: .make(plannable_type: "calendar_event"))
        XCTAssertEqual(p.icon(), UIImage.calendarMonthLine)
        p = Plannable.make(from: .make(plannable_type: "assessment_request"))
        XCTAssertEqual(p.icon(), UIImage.peerReviewLine)
    }

    func testColor() {
        ContextColor.make(canvasContextID: "course_2", color: .blue)
        ContextColor.make(canvasContextID: "group_7", color: .red)
        ContextColor.make(canvasContextID: "user_3", color: .brown)

        XCTAssertEqual(Plannable.make(from: .make(course_id: "2", context_type: "Course")).color, .blue)
        XCTAssertEqual(Plannable.make(from: .make(group_id: "7", context_type: "Group")).color, .red)
        XCTAssertEqual(Plannable.make(from: .make(group_id: "8", context_type: "Group")).color, .textDark)
        XCTAssertEqual(Plannable.make(from: .make(user_id: "3", context_type: "User")).color, .brown)
        XCTAssertEqual(Plannable.make(from: .make(course_id: "0", context_type: "Course")).color, .textDark)
    }

    func testK5Color() {
        ExperimentalFeature.K5Dashboard.isEnabled = true
        environment.k5.userDidLogin(isK5Account: true)
        environment.k5.sessionDefaults = environment.userDefaults
        environment.userDefaults?.isElementaryViewEnabled = true
        Course.make(from: .make(id: "2", course_color: "#0DEAD0"))
        Course.make(from: .make(id: "0", course_color: nil))
        ContextColor.make(canvasContextID: "course_2", color: .blue)
        ContextColor.make(canvasContextID: "group_7", color: .red)
        ContextColor.make(canvasContextID: "user_3", color: .brown)

        XCTAssertEqual(Plannable.make(from: .make(course_id: "2", context_type: "Course")).color.hexString, UIColor(hexString: "#0DEAD0")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(Plannable.make(from: .make(group_id: "7", context_type: "Group")).color, .red)
        XCTAssertEqual(Plannable.make(from: .make(group_id: "8", context_type: "Group")).color, .textDark)
        XCTAssertEqual(Plannable.make(from: .make(user_id: "3", context_type: "User")).color, .brown)
        XCTAssertEqual(Plannable.make(from: .make(course_id: "0", context_type: "Course")).color, .textDarkest) // default K5 `Course.color`
        XCTAssertEqual(Plannable.make(from: .make(course_id: "unsaved id", context_type: "Course")).color, .textDarkest)
    }
}
