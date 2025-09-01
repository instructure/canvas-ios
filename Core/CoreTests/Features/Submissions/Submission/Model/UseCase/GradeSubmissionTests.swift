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

class GradeSubmissionTests: CoreTestCase {
    func testGrading() throws {
        let model = Submission.make()
        let useCase = GradeSubmission(courseID: "1", assignmentID: model.assignmentID, userID: model.userID, rubricAssessment: [ "1": .make() ])
        api.mock(useCase, value: .make(
            entered_grade: "23",
            entered_score: 23,
            excused: false,
            grade: "23",
            grade_matches_current_submission: true,
            late: true,
            late_policy_status: .late,
            missing: nil,
            points_deducted: 2,
            rubric_assessment: nil, // API response doesn't include this field, GradeSubmission saves rubric assessment received during init
            score: 23,
            workflow_state: .graded
        ))
        useCase.fetch()
        XCTAssertEqual(model.enteredGrade, "23")
        XCTAssertEqual(model.enteredScore, 23)
        XCTAssertEqual(model.excused, false)
        XCTAssertEqual(model.grade, "23")
        XCTAssertEqual(model.gradeMatchesCurrentSubmission, true)
        XCTAssertEqual(model.late, true)
        XCTAssertEqual(model.latePolicyStatus, .late)
        XCTAssertEqual(model.missing, false)
        XCTAssertEqual(model.pointsDeducted, 2)
        XCTAssertEqual(model.rubricAssessments?.isEmpty, false)
        XCTAssertEqual(model.score, 23)
        XCTAssertEqual(model.workflowState, .graded)
    }
}
