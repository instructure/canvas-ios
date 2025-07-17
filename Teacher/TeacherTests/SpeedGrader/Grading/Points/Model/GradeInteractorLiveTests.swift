//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Combine
@testable import Core
import TestsFoundation
@testable import Teacher

class GradeInteractorLiveTests: TeacherTestCase {

    // MARK: - Grade State Publishing Tests

    func test_gradeState_publishesInitialStateAndUpdatesWhenCoreDataChanges() {
        let assignment = Assignment.make(from: .make(points_possible: 100), in: databaseClient)
        let submission = Submission.make(from: .make(grade: nil), in: databaseClient)
        let rubricInteractor = RubricGradingInteractorMock()
        let gradeStateInteractor = GradeStateInteractorMock()

        rubricInteractor.isRubricScoreAvailable.value = false
        rubricInteractor.totalRubricScore.value = 0
        let initialGradeState = GradeState(
            hasLateDeduction: false,
            isGraded: false,
            isExcused: false,
            isGradedButNotPosted: false,
            originalGradeText: "",
            pointsDeductedText: "0 pts",
            gradeAlertText: "",
            score: 0,
            pointsPossibleText: "",
            gradingType: .points,
            originalScoreWithoutMetric: nil,
            finalGradeWithoutMetric: nil
        )
        gradeStateInteractor.gradeStateToReturn = initialGradeState

        // WHEN
        let interactor = GradeInteractorLive(
            assignment: assignment,
            submission: submission,
            rubricGradingInteractor: rubricInteractor,
            gradeStateInteractor: gradeStateInteractor,
            env: environment
        )

        // THEN
        waitUntil(shouldFail: true) {
            gradeStateInteractor.gradeStateCalled
        }
        XCTAssertFirstValue(interactor.gradeState) { gradeState in
            XCTAssertEqual(gradeState, initialGradeState)
        }
        XCTAssertEqual(gradeStateInteractor.lastIsRubricScoreAvailable, false)
        XCTAssertEqual(gradeStateInteractor.lastTotalRubricScore, 0)

        // WHEN
        rubricInteractor.isRubricScoreAvailable.value = true
        rubricInteractor.totalRubricScore.value = 85.5
        let updatedGradeState = GradeState(
            hasLateDeduction: false,
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            originalGradeText: "90/100",
            pointsDeductedText: "0 pts",
            gradeAlertText: "90",
            score: 90,
            pointsPossibleText: "100 pts",
            gradingType: .points,
            originalScoreWithoutMetric: "90",
            finalGradeWithoutMetric: "90"
        )
        gradeStateInteractor.gradeStateToReturn = updatedGradeState
        gradeStateInteractor.gradeStateCalled = false

        submission.grade = "90"
        submission.score = 90
        try! databaseClient.save()

        // THEN
        waitUntil(shouldFail: true) {
            gradeStateInteractor.gradeStateCalled
        }
        XCTAssertFirstValue(interactor.gradeState) { gradeState in
            XCTAssertEqual(gradeState, updatedGradeState)
        }
        XCTAssertEqual(gradeStateInteractor.lastIsRubricScoreAvailable, true)
        XCTAssertEqual(gradeStateInteractor.lastTotalRubricScore, 85.5)
    }

    // MARK: - Save Grade API Tests

    func test_saveGrade_passesCorrectParametersToAPI() {
        let assignment = Assignment.make(from: .make(
            course_id: "course1",
            id: "assignment1"
        ), in: databaseClient)
        let submission = Submission.make(from: .make(
            assignment_id: "assignment1",
            user_id: "user1"
        ), in: databaseClient)
        let rubricInteractor = RubricGradingInteractorMock()

        let apiExpectation = expectation(description: "API called with correct parameters")
        let request = PutSubmissionGradeRequest(
            courseID: "course1",
            assignmentID: "assignment1",
            userID: "user1",
            body: nil // only the path and url parameters are used for mock lookup so
                      // we need to validate the actual body when we respond to the mock call
        )

        api.mock(request) { urlRequest in
            if let httpBody = urlRequest.httpBody {
                let body = try? JSONDecoder().decode(PutSubmissionGradeRequest.Body.self, from: httpBody)
                XCTAssertEqual("95", body?.submission?.posted_grade)
                XCTAssertEqual(body?.submission?.excuse, true)
                apiExpectation.fulfill()
            }
            return (nil, nil, nil)
        }

        let interactor = GradeInteractorLive(
            assignment: assignment,
            submission: submission,
            rubricGradingInteractor: rubricInteractor,
            env: environment
        )

        // WHEN
        XCTAssertFinish(interactor.saveGrade(excused: true, grade: "95"))

        // THEN
        waitForExpectations(timeout: 1)
    }
}

// MARK: - Mock Classes

private class GradeStateInteractorMock: GradeStateInteractor {
    var gradeStateCalled = false
    var gradeStateToReturn = GradeState.empty
    var lastSubmission: Submission?
    var lastAssignment: Assignment?
    var lastIsRubricScoreAvailable: Bool?
    var lastTotalRubricScore: Double?

    func gradeState(
        submission: Submission,
        assignment: Assignment,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState {
        gradeStateCalled = true
        lastSubmission = submission
        lastAssignment = assignment
        lastIsRubricScoreAvailable = isRubricScoreAvailable
        lastTotalRubricScore = totalRubricScore
        return gradeStateToReturn
    }
}
