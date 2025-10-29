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

    private static let testData = (
        courseId: "some courseId",
        assignmentId: "some assignmentId",
        userId: "some userId"
    )
    private lazy var testData = Self.testData

    private var assignment: Assignment!
    private var submission: Submission!
    private var gradingScheme: GradingScheme!
    private var rubricGradingInteractor: RubricGradingInteractorMock!
    private var gradeStateInteractor: GradeStateInteractorMock!

    override func setUp() {
        super.setUp()

        assignment = Assignment.make(in: databaseClient)
        assignment.id = testData.assignmentId
        assignment.courseID = testData.courseId

        submission = Submission.make(in: databaseClient)
        submission.userID = testData.userId

        gradingScheme = PercentageBasedGradingScheme.default

        rubricGradingInteractor = .init()
        gradeStateInteractor = .init()
    }

    override func tearDown() {
        assignment = nil
        submission = nil
        rubricGradingInteractor = nil
        gradeStateInteractor = nil
        super.tearDown()
    }

    // MARK: - Grade State Publishing Tests

    func test_gradeState_publishesInitialStateAndUpdatesWhenCoreDataChanges() throws {
        let initialGradeState = GradeState.make(score: 10)
        let updatedGradeState = GradeState.make(score: 20)

        rubricGradingInteractor.isRubricScoreAvailable.value = true
        rubricGradingInteractor.totalRubricScore.value = 100
        gradeStateInteractor.gradeStateOutput = initialGradeState

        // WHEN
        let testee = makeInteractor()

        // THEN
        XCTAssertSingleOutputEquals(testee.gradeState, initialGradeState)
        XCTAssertEqual(gradeStateInteractor.gradeStateCallsCount, 1)
        var gradeStateInput = try XCTUnwrap(gradeStateInteractor.gradeStateInput)
        XCTAssert(gradeStateInput == (submission, assignment, true, 100))

        // WHEN
        rubricGradingInteractor.isRubricScoreAvailable.value = false
        rubricGradingInteractor.totalRubricScore.value = 200
        gradeStateInteractor.gradeStateOutput = updatedGradeState

        submission.grade = "90"
        try! databaseClient.save()

        // THEN
        XCTAssertSingleOutputEquals(testee.gradeState, updatedGradeState)
        XCTAssertEqual(gradeStateInteractor.gradeStateCallsCount, 4) // initial + rubric + rubric + submission
        gradeStateInput = try XCTUnwrap(gradeStateInteractor.gradeStateInput)
        XCTAssert(gradeStateInput == (submission, assignment, false, 200))
    }

    // MARK: - Save Grade API Tests

    func test_saveGrade_passesCorrectParametersToAPI() {
        let apiExpectation = expectation(description: "API called with correct parameters")
        let request = PutSubmissionGradeRequest(
            courseID: testData.courseId,
            assignmentID: testData.assignmentId,
            userID: testData.userId,
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

        let testee = makeInteractor()

        // WHEN
        XCTAssertFinish(testee.saveGrade(excused: true, grade: "95"))

        // THEN
        waitForExpectations(timeout: 1)
    }

    private func makeInteractor() -> GradeInteractorLive {
        GradeInteractorLive(
            assignment: assignment,
            submission: submission,
            gradingScheme: gradingScheme,
            rubricGradingInteractor: rubricGradingInteractor,
            gradeStateInteractor: gradeStateInteractor,
            env: environment
        )
    }
}
