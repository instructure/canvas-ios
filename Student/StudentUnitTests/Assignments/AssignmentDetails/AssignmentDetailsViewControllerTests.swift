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

import Foundation
@testable import Student
import XCTest
import TestsFoundation
import Core

class AssignmentDetailsViewControllerTests: PersistenceTestCase {
    var courseID = "1"
    var assignmentID = "1"
    var viewController: AssignmentDetailsViewController!

    override func setUp() {
        super.setUp()
        env.mockStore = false
        viewController = AssignmentDetailsViewController.create(env: env, courseID: courseID, assignmentID: assignmentID)
    }

    func load() {
        XCTAssertNotNil(viewController.view)
    }

    func testNeedsGradingAndGraded() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded,
                grade_matches_current_submission: false
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testGradedAndResubmitted() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .submitted,
                grade_matches_current_submission: false
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testNeedsGrading() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                score: nil,
                submission_type: .discussion_topic,
                workflow_state: .pending_review
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertFalse(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertTrue(viewController.gradedView!.isHidden)
    }

    func testNeedsGradingAndExcused() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                excused: true,
                workflow_state: .pending_review
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testGraded() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: "10",
                score: 10,
                submission_type: .discussion_topic,
                workflow_state: .graded
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertFalse(viewController.gradeSection!.isHidden)
        XCTAssertFalse(viewController.gradedView!.isHidden)
    }

    func testUnsubmittedAndGradeRemoved() {
        let course = APICourse.make(id: ID(courseID))
        api.mock(viewController.presenter!.courses, value: course)
        let assignment = APIAssignment.make(
            id: ID(assignmentID),
            course_id: ID(courseID),
            submission: .make(
                grade: nil,
                score: nil,
                submission_type: nil,
                workflow_state: .graded
            )
        )
        api.mock(viewController.presenter!.assignments, value: assignment)
        load()
        drainMainQueue()
        XCTAssertTrue(viewController.submittedView!.isHidden)
        XCTAssertTrue(viewController.gradeSection!.isHidden)
        XCTAssertTrue(viewController.gradedView!.isHidden)

    }
}
