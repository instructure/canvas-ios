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
        let apiPlannable = APIPlannable.make(
            course_id: ID(TestConstants.courseId),
            group_id: ID(TestConstants.groupId),
            user_id: ID(TestConstants.userId),
            context_type: "Course",
            plannable_id: ID(TestConstants.plannableId),
            plannable_type: PlannableType.assignment.rawValue,
            html_url: TestConstants.htmlUrl,
            context_name: TestConstants.contextName,
            plannable: .make(
                title: TestConstants.plannableTitle,
                details: TestConstants.plannableDetails,
                points_possible: TestConstants.pointsPossible,
                sub_assignment_tag: "reply_to_entry"
            ),
            plannable_date: TestConstants.plannableDate,
            details: .make(reply_to_entry_required_count: 42)
        )

        let plannable = Plannable.save(apiPlannable, userId: "another userId", in: databaseClient)

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
        XCTAssertEqual(plannable.discussionCheckpointStep, .requiredReplies(42))
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
        XCTAssertEqual(p.icon, UIImage.assignmentLine)

        p = Plannable.make(from: .make(plannable_type: "quiz"))
        XCTAssertEqual(p.icon, UIImage.quizLine)

        p = Plannable.make(from: .make(plannable_type: "discussion_topic"))
        XCTAssertEqual(p.icon, UIImage.discussionLine)

        p = Plannable.make(from: .make(plannable_type: "sub_assignment"))
        XCTAssertEqual(p.icon, UIImage.assignmentLine)

        p = Plannable.make(from: .make(plannable_type: "sub_assignment"))
        p.discussionCheckpointStep = .replyToTopic
        XCTAssertEqual(p.icon, UIImage.discussionLine)

        p = Plannable.make(from: .make(plannable_type: "wiki_page"))
        XCTAssertEqual(p.icon, UIImage.documentLine)

        p = Plannable.make(from: .make(plannable_type: "planner_note"))
        XCTAssertEqual(p.icon, UIImage.noteLine)

        p = Plannable.make(from: .make(plannable_type: "other"))
        XCTAssertEqual(p.icon, UIImage.warningLine)

        p = Plannable.make(from: .make(plannable_type: "announcement"))
        XCTAssertEqual(p.icon, UIImage.announcementLine)

        p = Plannable.make(from: .make(plannable_type: "calendar_event"))
        XCTAssertEqual(p.icon, UIImage.calendarMonthLine)
        p = Plannable.make(from: .make(plannable_type: "assessment_request"))
        XCTAssertEqual(p.icon, UIImage.peerReviewLine)
    }

    func testColor() {
        ContextColor.make(canvasContextID: "course_2", color: .blue)
        ContextColor.make(canvasContextID: "group_7", color: .red)
        ContextColor.make(canvasContextID: "user_3", color: .brown)

        XCTAssertEqual(
            Plannable.make(from: .make(course_id: "2", context_type: "Course")).color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(.blue).hexString
        )
        XCTAssertEqual(
            Plannable.make(from: .make(group_id: "7", context_type: "Group")).color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(.red).hexString
        )
        XCTAssertEqual(
            Plannable.make(from: .make(group_id: "8", context_type: "Group")).color,
            .textDark
        )
        XCTAssertEqual(
            Plannable.make(from: .make(user_id: "3", context_type: "User")).color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(.brown).hexString
        )
        XCTAssertEqual(
            Plannable.make(from: .make(course_id: "0", context_type: "Course")).color,
            .textDark
        )
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
        XCTAssertEqual(
            Plannable.make(from: .make(group_id: "7", context_type: "Group")).color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(.red).hexString
        )
        XCTAssertEqual(
            Plannable.make(from: .make(group_id: "8", context_type: "Group")).color,
            .textDark
        )
        XCTAssertEqual(
            Plannable.make(from: .make(user_id: "3", context_type: "User")).color.hexString,
            CourseColorsInteractorLive().courseColorFromAPIColor(.brown).hexString
        )
        XCTAssertEqual(
            Plannable.make(from: .make(course_id: "0", context_type: "Course")).color,
            .textDarkest // default K5 `Course.color`
        )
        XCTAssertEqual(
            Plannable.make(from: .make(course_id: "unsaved id", context_type: "Course")).color,
            .textDarkest
        )
    }

    func testContextNameUserFacing() {
        // not ToDo, without context name
        var testee = Plannable.make(from: .make(plannable_type: "calendar_event", context_name: nil))
        XCTAssertEqual(testee.contextName, nil)
        XCTAssertEqual(testee.contextNameUserFacing, nil)

        // not ToDo, with context name
        testee = Plannable.make(from: .make(plannable_type: "calendar_event", context_name: TestConstants.contextName))
        XCTAssertEqual(testee.contextName, TestConstants.contextName)
        XCTAssertEqual(testee.contextNameUserFacing, TestConstants.contextName)

        // ToDo, without context name
        testee = Plannable.make(from: .make(plannable_type: "planner_note", context_name: nil))
        XCTAssertEqual(testee.contextName, nil)
        XCTAssertEqual(testee.contextNameUserFacing, "To Do")

        // ToDo, with context name
        testee = Plannable.make(from: .make(plannable_type: "planner_note", context_name: TestConstants.contextName))
        XCTAssertEqual(testee.contextName, TestConstants.contextName)
        XCTAssertEqual(testee.contextNameUserFacing, TestConstants.contextName + " To Do")
    }

    func testIsMarkedCompleteFromAPIPlannable() {
        let apiPlannableWithOverride = APIPlannable.make(
            planner_override: .make(marked_complete: true),
            plannable_id: ID("1")
        )
        let plannableMarkedComplete = Plannable.save(apiPlannableWithOverride, userId: "user1", in: databaseClient)
        XCTAssertTrue(plannableMarkedComplete.isMarkedComplete)

        let apiPlannableWithoutOverride = APIPlannable.make(
            planner_override: nil,
            plannable_id: ID("2")
        )
        let plannableNotMarkedComplete = Plannable.save(apiPlannableWithoutOverride, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannableNotMarkedComplete.isMarkedComplete)

        let apiPlannableWithFalseOverride = APIPlannable.make(
            planner_override: .make(marked_complete: false),
            plannable_id: ID("3")
        )
        let plannableWithFalseOverride = Plannable.save(apiPlannableWithFalseOverride, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannableWithFalseOverride.isMarkedComplete)
    }

    func testIsMarkedCompleteFromAPIPlannerNote() {
        let apiPlannerNote = APIPlannerNote.make(id: "note1")
        let plannable = Plannable.save(apiPlannerNote, contextName: "Context", in: databaseClient)
        XCTAssertFalse(plannable.isMarkedComplete)
    }

    func testIsMarkedCompleteFromAPICalendarEvent() {
        let apiCalendarEvent = APICalendarEvent.make(id: ID("event1"))
        let plannable = Plannable.save(apiCalendarEvent, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannable.isMarkedComplete)
    }

    func testIsSubmittedFromAPIPlannable() {
        let apiPlannableWithSubmission = APIPlannable.make(
            plannable_id: ID("1"),
            submissions: .make(submitted: true)
        )
        let plannableSubmitted = Plannable.save(apiPlannableWithSubmission, userId: "user1", in: databaseClient)
        XCTAssertTrue(plannableSubmitted.isSubmitted)

        let apiPlannableWithoutSubmission = APIPlannable.make(
            plannable_id: ID("2"),
            submissions: nil
        )
        let plannableNotSubmitted = Plannable.save(apiPlannableWithoutSubmission, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannableNotSubmitted.isSubmitted)

        let apiPlannableWithFalseSubmission = APIPlannable.make(
            plannable_id: ID("3"),
            submissions: .make(submitted: false)
        )
        let plannableWithFalseSubmission = Plannable.save(apiPlannableWithFalseSubmission, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannableWithFalseSubmission.isSubmitted)
    }

    func testIsSubmittedFromAPIPlannerNote() {
        let apiPlannerNote = APIPlannerNote.make(id: "note1")
        let plannable = Plannable.save(apiPlannerNote, contextName: "Context", in: databaseClient)
        XCTAssertFalse(plannable.isSubmitted)
    }

    func testIsSubmittedFromAPICalendarEvent() {
        let apiCalendarEvent = APICalendarEvent.make(id: ID("event1"))
        let plannable = Plannable.save(apiCalendarEvent, userId: "user1", in: databaseClient)
        XCTAssertFalse(plannable.isSubmitted)
    }

    func testShouldShowInTodoListForAssignments() {
        let assignmentNotCompleted = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("assignment1"),
                plannable_type: PlannableType.assignment.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertTrue(assignmentNotCompleted.shouldShowInTodoList)

        let assignmentCompleted = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: true),
                plannable_id: ID("assignment2"),
                plannable_type: PlannableType.assignment.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(assignmentCompleted.shouldShowInTodoList)

        let submittedAssignment = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("assignment3"),
                plannable_type: PlannableType.assignment.rawValue,
                submissions: .make(submitted: true)
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(submittedAssignment.shouldShowInTodoList)

        let completedAndSubmittedAssignment = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: true),
                plannable_id: ID("assignment4"),
                plannable_type: PlannableType.assignment.rawValue,
                submissions: .make(submitted: true)
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(completedAndSubmittedAssignment.shouldShowInTodoList)
    }

    func testShouldShowInTodoListForQuizzes() {
        let quiz = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("quiz1"),
                plannable_type: PlannableType.quiz.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertTrue(quiz.shouldShowInTodoList)

        let submittedQuiz = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("quiz2"),
                plannable_type: PlannableType.quiz.rawValue,
                submissions: .make(submitted: true)
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(submittedQuiz.shouldShowInTodoList)
    }

    func testShouldShowInTodoListForDiscussions() {
        let discussionTopic = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("discussion1"),
                plannable_type: PlannableType.discussion_topic.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertTrue(discussionTopic.shouldShowInTodoList)

        let submittedDiscussion = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("discussion2"),
                plannable_type: PlannableType.discussion_topic.rawValue,
                submissions: .make(submitted: true)
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(submittedDiscussion.shouldShowInTodoList)
    }

    func testShouldShowInTodoListForNonTodoTypes() {
        let announcement = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("announcement1"),
                plannable_type: PlannableType.announcement.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(announcement.shouldShowInTodoList)

        let assessmentRequest = Plannable.save(
            APIPlannable.make(
                planner_override: .make(marked_complete: false),
                plannable_id: ID("assessment1"),
                plannable_type: PlannableType.assessment_request.rawValue
            ),
            userId: "user1",
            in: databaseClient
        )
        XCTAssertFalse(assessmentRequest.shouldShowInTodoList)
    }
}
