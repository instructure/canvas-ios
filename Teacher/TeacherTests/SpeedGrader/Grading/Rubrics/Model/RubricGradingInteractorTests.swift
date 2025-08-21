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
@testable import Teacher

class RubricGradingInteractorTests: TeacherTestCase {

    // MARK: - Properties

    private var testData = (
        courseId: "course_1",
        assignmentId: "assignment_1",
        userId: "user_1",
        submissionId: "submission_1"
    )

    private var interactor: RubricGradingInteractorLive!
    private var assignment: Assignment!
    private var submission: Submission!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Setup and Teardown

    override func setUp() {
        super.setUp()

        assignment = Assignment.make(
            from: .make(
                course_id: ID(testData.courseId),
                id: ID(testData.assignmentId),
                rubric: [
                    .make(description: "Criterion 1", id: "criterion_1", points: 10.0),
                    .make(description: "Criterion 2", id: "criterion_2", points: 5.0),
                    .make(description: "Criterion 3", id: "criterion_3", ignore_for_scoring: true, points: 15.0)
                ],
                use_rubric_for_grading: true
            ),
            in: databaseClient
        )
        assignment.id = testData.assignmentId
        assignment.courseID = testData.courseId

        submission = Submission.make(
            from: .make(
                id: testData.submissionId,
                rubric_assessment: [
                    "criterion_1": .init(
                        comments: "comment",
                        points: 5
                    )
                ],
                user_id: testData.userId
            ),
            in: databaseClient
        )
        submission.userID = testData.userId

        interactor = RubricGradingInteractorLive(assignment: assignment, submission: submission, env: environment)
    }

    override func tearDown() {
        interactor = nil
        assignment = nil
        submission = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_initialState_calculatesTotalScoreCorrectly() {
        XCTAssertEqual(interactor.totalRubricScore.value, 5.0)
    }

    func test_initialState_setsAssessmentsFromSubmission() {
        let expectation = expectation(description: "Assessments are published on init")
        interactor.assessments
            .sink { assessments in
                XCTAssertEqual(assessments["criterion_1"]?.points, 5)
                XCTAssertEqual(assessments["criterion_1"]?.comments, "comment")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        waitForExpectations(timeout: 1.0)
    }

    func test_initialState_setsIsRubricScoreAvailable() {
        XCTAssertTrue(interactor.isRubricScoreAvailable.value)
    }

    func test_initialState_isRubricScoreAvailable_whenNoInitialScore() {
        submission = Submission.make(from: .make(rubric_assessment: [:]))
        interactor = RubricGradingInteractorLive(assignment: assignment, submission: submission, env: environment)
        XCTAssertFalse(interactor.isRubricScoreAvailable.value)
    }

    func test_initialState_isRubricScoreAvailable_whenUseRubricForGradingIsFalse() {
        assignment = Assignment.make(from: .make(use_rubric_for_grading: false))
        interactor = RubricGradingInteractorLive(assignment: assignment, submission: submission, env: environment)
        XCTAssertFalse(interactor.isRubricScoreAvailable.value)
    }

    // MARK: - Functionality Tests

    func test_clearRating_removesPointsButKeepsComment() {
        interactor.clearRating(criterionId: "criterion_1")

        let expectation = expectation(description: "Rating is cleared but comment is kept")
        interactor.assessments
            .sink { assessments in
                XCTAssertNil(assessments["criterion_1"]?.points)
                XCTAssertEqual(assessments["criterion_1"]?.comments, "comment")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(interactor.totalRubricScore.value, 0.0)
    }

    func test_selectRating_updatesPointsAndRatingId() {
        interactor.selectRating(criterionId: "criterion_2", points: 3.0, ratingId: "rating_2")

        let expectation = expectation(description: "Rating is selected")
        interactor.assessments
            .sink { assessments in
                // We only care about the latest value
                if assessments["criterion_2"]?.points == 3.0 {
                    XCTAssertEqual(assessments["criterion_2"]?.rating_id, "rating_2")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(interactor.totalRubricScore.value, 8.0)
    }

    func test_updateComment_changesCommentButPreservesPoints() {
        interactor.updateComment(criterionId: "criterion_1", comment: "updated comment")

        let expectation = expectation(description: "Comment is updated")
        interactor.assessments
            .sink { assessments in
                if assessments["criterion_1"]?.comments == "updated comment" {
                    XCTAssertEqual(assessments["criterion_1"]?.points, 5)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0)
    }

    func test_hasAssessmentUserComment_returnsCorrectly() {
        XCTAssertTrue(interactor.hasAssessmentUserComment(criterionId: "criterion_1"))
        XCTAssertFalse(interactor.hasAssessmentUserComment(criterionId: "criterion_2"))
    }

    func test_totalRubricScore_ignoresCriteriaWithIgnoreForScoring() {
        interactor.selectRating(criterionId: "criterion_2", points: 5.0, ratingId: "rating_x")
        interactor.selectRating(criterionId: "criterion_3", points: 10.0, ratingId: "rating_y")

        XCTAssertEqual(interactor.totalRubricScore.value, 10.0)
    }

    // MARK: - Grade Upload Tests

    func test_uploadGrades_setsIsSavingToTrue() {
        let expectation = expectation(description: "isSaving becomes true during upload")
        interactor.isSaving
            .first(where: { $0 == true })
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        interactor.selectRating(criterionId: "criterion_2", points: 1.0, ratingId: "r1")

        waitForExpectations(timeout: 1.0)
    }

    func test_uploadGrades_success_setsIsSavingToFalse() {
        let expectation = expectation(description: "isSaving becomes false after successful upload")
        interactor.isSaving
            .dropFirst(2)
            .sink { isSaving in
                XCTAssertFalse(isSaving)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        let updatedAssessments: APIRubricAssessmentMap = [
            "criterion_1": .init(comments: "comment", points: 5),
            "criterion_2": .init(points: 1.0, rating_id: "r1")
        ]

        let request = GradeSubmission(courseID: assignment.courseID, assignmentID: assignment.id, userID: submission.userID, rubricAssessment: updatedAssessments)
        api.mock(request, value: nil)

        interactor.selectRating(criterionId: "criterion_2", points: 1.0, ratingId: "r1")

        waitForExpectations(timeout: 1.0)
    }

    func test_uploadGrades_failure_sendsErrorAndSetsIsSavingToFalse() {
        let errorExpectation = expectation(description: "showSaveError sends an error on failure")
        let savingExpectation = expectation(description: "isSaving becomes false after failed upload")
        let expectedError = NSError(domain: "TestError", code: 123, userInfo: nil)

        interactor.showSaveError
            .sink { error in
                XCTAssertEqual(error as NSError, expectedError)
                errorExpectation.fulfill()
            }
            .store(in: &cancellables)

        interactor.isSaving
            .dropFirst(2)
            .sink { isSaving in
                XCTAssertFalse(isSaving)
                savingExpectation.fulfill()
            }
            .store(in: &cancellables)

        let updatedAssessments: APIRubricAssessmentMap = [
            "criterion_1": .init(comments: "comment", points: 5),
            "criterion_2": .init(points: 1.0, rating_id: "r1")
        ]
        let request = GradeSubmission(courseID: assignment.courseID, assignmentID: assignment.id, userID: submission.userID, rubricAssessment: updatedAssessments)
        api.mock(request, error: expectedError)

        interactor.selectRating(criterionId: "criterion_2", points: 1.0, ratingId: "r1")

        waitForExpectations(timeout: 1.0)
    }

    func test_uploadGrades_assessmentChangedDuringUpload_startsNewUpload() {
        let expectation = expectation(description: "isSaving sequence should be true, false, true, false")
        var savingStates: [Bool] = []
        interactor.isSaving
            .dropFirst()
            .sink { isSaving in
                savingStates.append(isSaving)
                if savingStates == [true, false, true, false] {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        let firstAssessments: APIRubricAssessmentMap = [
            "criterion_1": .init(comments: "comment", points: 5),
            "criterion_2": .init(points: 2.0, rating_id: "r2")
        ]
        let request1 = GradeSubmission(courseID: assignment.courseID, assignmentID: assignment.id, userID: submission.userID, rubricAssessment: firstAssessments)
        let mock1 = api.mock(request1, value: nil)
        mock1.suspend()

        let secondAssessments: APIRubricAssessmentMap = [
            "criterion_1": .init(comments: "another comment", points: 5),
            "criterion_2": .init(points: 2.0, rating_id: "r2")
        ]
        let request2 = GradeSubmission(courseID: assignment.courseID, assignmentID: assignment.id, userID: submission.userID, rubricAssessment: secondAssessments)
        api.mock(request2, value: nil)

        interactor.selectRating(criterionId: "criterion_2", points: 2.0, ratingId: "r2")

        interactor.updateComment(criterionId: "criterion_1", comment: "another comment")

        mock1.resume()

        waitForExpectations(timeout: 2.0)
    }
}
