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

class SpeedGraderRubricUITests: MiniCanvasUITestCase {
    lazy var student = mocked.students.first!
    lazy var submission = firstAssignment.submission(byUserId: student.id.value)!

    func showSubmission() {
        show("/courses/\(firstCourse.id)/assignments/\(firstAssignment.id)/submissions/\(student.id.value)", options: .modal(.fullScreen))
    }

    func testAddComment() throws {
        firstAssignment.api.rubric_settings = .make(free_form_criterion_comments: true)
        firstAssignment.api.rubric = [ APIRubric.make() ]

        showSubmission()
        SpeedGrader.setDrawerState(.max)
        SpeedGrader.Segment.grades.tap()
        SpeedGrader.Rubric.addCommentButton(id: "1").tap()
        SubmissionComments.commentTextView.pasteText(":facepalm:") // typeText fails to think it's focused in SwiftUI

        let expectation = MiniCanvasServer.shared.expectationFor(
            request: PutSubmissionGradeRequest(
                courseID: firstCourse.id,
                assignmentID: firstAssignment.id,
                userID: student.id.value
            )
        )
        SubmissionComments.addCommentButton.tap()
        SpeedGrader.doneButton.tapUntil { !SpeedGrader.doneButton.exists }
        wait(for: [expectation], timeout: 9)

        XCTAssertEqual(submission.api.rubric_assessment?["1"]?.comments, ":facepalm:")
    }
/*
    func testSetScore() throws {
        showSubmission()
        SpeedGrader.Segment.grades.tap()

        throw XCTSkip("unfinished test")
    }

    func testCusomizeScore() throws {
        firstAssignment.api.rubric = [ APIRubric.make() ]

        showSubmission()
        SpeedGrader.Segment.grades.tap()

        let customizeButton = app.find(id: "rubric-item.customize-grade-1")

        XCTAssertEqual(customizeButton.label(), "Customize Grade")
        customizeButton.tap()
        app.alerts.textFields.firstElement.typeText("200")
        app.alerts.buttons["OK"].tap()

        XCTAssertEqual(customizeButton.label(), "Customize Grade 200")
        customizeButton.tap()
        XCTAssertEqual(customizeButton.label(), "Customize Grade")

        throw XCTSkip("unfinished test")
    }
*/
}
