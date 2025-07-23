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
import CombineSchedulers
@testable import Core
import TestsFoundation
@testable import Teacher

class SpeedGraderSubmissionGradesViewModelTests: TeacherTestCase {
    private enum TestData {
        static let sampleGradeState = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )
    }
    private var gradeInteractorMock: GradeInteractorMock!
    private var viewModel: SpeedGraderSubmissionGradesViewModel!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        gradeInteractorMock = GradeInteractorMock()
        cancellables = Set<AnyCancellable>()

        let assignment = Assignment.make(from: .make(), in: databaseClient)
        let submission = Submission.make(from: .make(), in: databaseClient)

        viewModel = SpeedGraderSubmissionGradesViewModel(
            assignment: assignment,
            submission: submission,
            gradeInteractor: gradeInteractorMock,
            mainScheduler: .immediate
        )
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        gradeInteractorMock = nil
        super.tearDown()
    }

    // MARK: - Grade State Updates

    func test_gradeStateChanges_updateStateAndSliderValue() {
        gradeInteractorMock.gradeStateSubject.send(TestData.sampleGradeState)

        XCTAssertEqual(viewModel.gradeState, TestData.sampleGradeState)
        XCTAssertEqual(viewModel.sliderValue, 85)
    }

    // MARK: - User Action Tests

    func test_removeGrade_callsSaveGradeWithEmptyString() {
        viewModel.removeGrade()

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "")
    }

    func test_excuseStudent_callsSaveGradeWithExcusedTrue() {
        viewModel.excuseStudent()

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertEqual(gradeInteractorMock.lastExcused, true)
        XCTAssertNil(gradeInteractorMock.lastGrade)
    }

    func test_setGrade_callsSaveGradeWithProvidedGrade() {
        viewModel.setGrade("A")

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "A")
    }

    func test_setPointsGrade_callsSaveGradeWithPointsAsString() {
        viewModel.setPointsGrade(87.5)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "87.5")
    }

    func test_setPercentGrade_callsSaveGradeWithRoundedPercent() {
        viewModel.setPercentGrade(87.3)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "87.0%")
    }

    func test_setPercentGrade_roundsCorrectly() {
        viewModel.setPercentGrade(87.7)

        XCTAssertEqual(gradeInteractorMock.lastGrade, "88.0%")
    }

    func test_setPassFailGrade_complete_callsSaveGradeWithComplete() {
        viewModel.setPassFailGrade(complete: true)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "complete")
    }

    func test_setPassFailGrade_incomplete_callsSaveGradeWithIncomplete() {
        viewModel.setPassFailGrade(complete: false)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "incomplete")
    }

    // MARK: - Saving State Tests

    func test_saveGrade_setsSavingStateCorrectly() {
        XCTAssertFalse(viewModel.isSaving)

        viewModel.setGrade("B")
        XCTAssertTrue(viewModel.isSaving)

        gradeInteractorMock.saveGradeSubject.send(completion: .finished)
        XCTAssertFalse(viewModel.isSaving)
    }

    func test_saveGradeSuccess_clearsSavingState() {
        viewModel.setGrade("A")
        XCTAssertTrue(viewModel.isSaving)

        gradeInteractorMock.saveGradeSubject.send(())
        gradeInteractorMock.saveGradeSubject.send(completion: .finished)

        XCTAssertFalse(viewModel.isSaving)
    }

    // MARK: - Error Handling Tests

    func test_saveGradeError_showsErrorAlert() {
        XCTAssertFalse(viewModel.isShowingErrorAlert)

        viewModel.setGrade("B")
        gradeInteractorMock.saveGradeSubject.send(completion: .failure(NSError.internalError()))

        XCTAssertEqual(viewModel.isShowingErrorAlert, true)
        XCTAssertEqual(viewModel.errorAlertViewModel.title, "Error")
        XCTAssertEqual(viewModel.errorAlertViewModel.message, "Internal Error")
        XCTAssertEqual(viewModel.errorAlertViewModel.buttonTitle, "OK")
        XCTAssertFalse(viewModel.isSaving)
    }

    func test_saveGradeError_clearsIsSavingState() {
        let error = NSError(domain: "TestError", code: 1)

        viewModel.excuseStudent()
        XCTAssertTrue(viewModel.isSaving)

        gradeInteractorMock.saveGradeSubject.send(completion: .failure(error))
        XCTAssertFalse(viewModel.isSaving)
    }

    // MARK: - No Grade Button Tests

    func test_isNoGradeButtonDisabled_withoutGradeAndNotExcused_isDisabled() {
        let stateWithoutGrade = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: false,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 0,
            originalScoreWithoutMetric: nil,
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: nil,
            pointsDeductedText: "",
            originalGradeText: "",
            gradeAlertText: ""
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithoutGrade)

        XCTAssertTrue(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withGrade_isEnabled() {
        let stateWithGrade = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withExcusedGrade_isEnabled() {
        let stateWithExcusedGrade = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: false,
            isExcused: true,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 0,
            originalScoreWithoutMetric: nil,
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "Excused",
            pointsDeductedText: "",
            originalGradeText: "Excused",
            gradeAlertText: "Excused"
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithExcusedGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }

    // MARK: - GradeState Extension Tests

    func test_pointsRowModel_returnsNilForPointsGradingWithoutLateDeduction() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        XCTAssertNil(state.pointsRowModel)
    }

    func test_pointsRowModel_returnsViewModelForPointsGradingWithLateDeduction() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: true,
            score: 85,
            originalScoreWithoutMetric: "95",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "10 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        let result = state.pointsRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.currentPoints, "95")
        XCTAssertEqual(result?.maxPointsWithUnit, "   / 100 pts")
    }

    func test_pointsRowModel_returnsViewModelForNonPointsGrading() {
        let state = GradeState(
            gradingType: .percent,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85%",
            gradeAlertText: "85"
        )

        let result = state.pointsRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.currentPoints, "85")
        XCTAssertEqual(result?.maxPointsWithUnit, "   / 100 pts")
    }

    func test_latePenaltyRowModel_returnsNilWhenNoLateDeduction() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        XCTAssertNil(state.latePenaltyRowModel)
    }

    func test_latePenaltyRowModel_returnsViewModelWhenHasLateDeduction() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: true,
            score: 85,
            originalScoreWithoutMetric: "95",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "-10 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        let result = state.latePenaltyRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.penaltyText, "-10 pts")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPointsGrading() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85/100",
            gradeAlertText: "85"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.currentGradeText, "85")
        XCTAssertEqual(result.suffixText, "   / 100 pts")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPercentGrading() {
        let state = GradeState(
            gradingType: .percent,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            originalGradeText: "85%",
            gradeAlertText: "85"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.currentGradeText, "85")
        XCTAssertEqual(result.suffixText, "   %")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForLetterGrading() {
        let state = GradeState(
            gradingType: .letter_grade,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 87,
            originalScoreWithoutMetric: "87",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "B+",
            pointsDeductedText: "0 pts",
            originalGradeText: "B+",
            gradeAlertText: "B+"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.currentGradeText, "B+")
        XCTAssertEqual(result.suffixText, "")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPassFailGrading() {
        let state = GradeState(
            gradingType: .pass_fail,
            pointsPossibleText: "100 pts",
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 100,
            originalScoreWithoutMetric: "100",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "Complete",
            pointsDeductedText: "0 pts",
            originalGradeText: "Complete",
            gradeAlertText: "Complete"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.currentGradeText, "Complete")
        XCTAssertEqual(result.suffixText, "")
    }

    func test_finalGradeRowModel_handlesNilFinalGradeWithoutMetric() {
        let state = GradeState(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            isGraded: false,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 0,
            originalScoreWithoutMetric: nil,
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: nil,
            pointsDeductedText: "0 pts",
            originalGradeText: "",
            gradeAlertText: ""
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.currentGradeText, "-")
        XCTAssertEqual(result.suffixText, "   / 100 pts")
    }
}
