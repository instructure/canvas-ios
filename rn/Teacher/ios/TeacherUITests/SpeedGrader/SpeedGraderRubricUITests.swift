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
import TestsFoundation
@testable import Core
@testable import CoreUITests

class SpeedGraderRubricUITests: MiniCanvasUITestCase {
    lazy var student = mocked.students.first!
    lazy var submission = firstAssignment.submission(byUserId: student.id.value)!

    func showSubmission() {
        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(submission.api.id)")
        SpeedGrader.dismissTutorial()
    }

    func testAddComment() throws {
        firstAssignment.api.rubric_settings = .make(free_form_criterion_comments: true)
        firstAssignment.api.rubric = [ APIRubric.make() ]

        showSubmission()
        SpeedGrader.segmentButton(label: "Grades").tap()
        app.find(id: "rubric-item.add-comment-1").tapUntil {
            SubmissionComments.commentTextView.exists
        }
        SubmissionComments.commentTextView.typeText(":facepalm:")
        SubmissionComments.addCommentButton.tap()

        let expectation = MiniCanvasServer.shared.expectationFor(
            request: PutSubmissionGradeRequest(
                courseID: firstCourse.id,
                assignmentID: firstAssignment.id,
                userID: student.id.value
            )
        )
        SpeedGrader.doneButton.tap()
        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(submission.api.rubric_assessment?["1"]?.comments, ":facepalm:")
    }
}
