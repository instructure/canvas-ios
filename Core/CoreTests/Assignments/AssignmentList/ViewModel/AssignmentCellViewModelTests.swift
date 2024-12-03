//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

class AssignmentCellViewModelTests: CoreTestCase {

    func testIcon() {
        let assignment = Assignment.make(from: .make(locked_for_user: true))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.icon, .lockLine)
        assignment.lockedForUser = false

        XCTAssertEqual(testee.icon, .assignmentLine)
    }

    func testName() {
        let assignment = Assignment.make(from: .make(name: "Test Assignment 3"))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.name, "Test Assignment 3")
    }

    func testSubmissionStatusAndIconAndColor() {
        let assignment = Assignment.make(from: .make(name: "Test Assignment 3"))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.submissionIcon, .noSolid)
        XCTAssertEqual(testee.submissionColor.hexString, "#697783")
        XCTAssertEqual(testee.submissionStatus, "Not Submitted")

        assignment.submission = Submission.make()
        assignment.submission?.submittedAt = Clock.now
        assignment.submission?.workflowState = .graded
        assignment.submission?.score = 1.0
        XCTAssertEqual(testee.submissionIcon, .completeSolid)
        XCTAssertEqual(testee.submissionColor.hexString, "#03893c")
        XCTAssertEqual(testee.submissionStatus, "Graded")
    }

    func testNeedsGrading() {
        let assignment = Assignment.make(from: .make(name: "Test Assignment 3"))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        assignment.needsGradingCount = 0
        XCTAssertFalse(testee.needsGrading)
        XCTAssertEqual(testee.needsGradingCount, 0)

        assignment.needsGradingCount = 1
        XCTAssertTrue(testee.needsGrading)
        XCTAssertEqual(testee.needsGradingCount, 1)
    }

    func testHasPointsPossibleAndPointsPossibleText() {
        let assignment = Assignment.make(from: .make(name: "Test Assignment 3"))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        assignment.pointsPossible = nil
        XCTAssertFalse(testee.hasPointsPossible)

        assignment.pointsPossible = 1.0
        XCTAssertTrue(testee.hasPointsPossible)
        XCTAssertEqual(testee.pointsPossibleText, assignment.pointsPossibleCompleteText)
    }

    func testPublishedAsTeacher() {
        environment.app = .teacher
        let assignment = Assignment.make(from: .make(published: true))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.published, true)
    }

    func testNotPublishedAsTeacher() {
        environment.app = .teacher
        let assignment = Assignment.make(from: .make(published: false))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.published, false)
    }

    func testPublishedAsStudent() {
        environment.app = .student
        let assignment = Assignment.make(from: .make(published: true))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertNil(testee.published)
    }

    func testTeacherRouteToDiscussionTopic() {
        environment.app = .teacher
        let assignment = Assignment.make(from: .make(course_id: "testCourse", discussion_topic: .make(id: "test")))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.route, URL(string: "/courses/testCourse/assignments/1"))
    }

    func testStudentRouteToAssignmentHTML() {
        environment.app = .student
        let assignment = Assignment.make(from: .make(html_url: URL(string: "testURL")!))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.route, URL(string: "testURL")!)
    }

    func testNotGradedAssignmentHasNoNeedsGradingText() {
        let assignment = Assignment.make(from: .make(grading_type: .not_graded, needs_grading_count: 1))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertNil(testee.needsGradingText)
    }

    func testGradableAssignmentGradingText() {
        var gradableTypes = GradingType.allCases
        gradableTypes.removeAll { $0 == .not_graded}

        for gradableType in gradableTypes {
            let assignment = Assignment.make(from: .make(grading_type: gradableType, needs_grading_count: 1))
            let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
            XCTAssertEqual(testee.needsGradingText, "1 Needs Grading")
            assignment.needsGradingCount = 2
            XCTAssertEqual(testee.needsGradingText, "2 Need Grading")
        }
    }

    func testDueDateLocked() {
        let assignment = Assignment.make(from: .make(lock_at: Clock.now.addSeconds(-1)))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.formattedDueDate, "Availability: Closed")
    }

    func testDueDateMultiple() {
        let assignment = Assignment.make(from: .make(all_dates: [.make(id: "1"), .make(id: "2")]))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.formattedDueDate, "Multiple Due Dates")
    }

    func testDueDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLL d, y h:mm a"
        let now = Clock.now
        let nowString = dateFormatter.string(from: now)
        let assignment = Assignment.make(from: .make(due_at: now))
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.formattedDueDate, "Due \(nowString)")
    }

    func testNoDue() {
        let assignment = Assignment.make(from: .make())
        let testee = AssignmentCellViewModel(assignment: assignment, courseColor: nil)
        XCTAssertEqual(testee.formattedDueDate, "No Due Date")
    }
}
