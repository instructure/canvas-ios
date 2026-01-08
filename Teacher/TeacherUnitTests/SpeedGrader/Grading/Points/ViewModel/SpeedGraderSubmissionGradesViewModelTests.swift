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
            pointsPossibleAccessibilityText: "100 points",
            gradeOptions: [],
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            hasLateDeduction: false,
            score: 85,
            originalGrade: nil,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts",
            pointsDeductedAccessibilityText: "0 points"
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
        viewModel.setGradeFromTextField("42", inputType: .points)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "42.0")
    }

    func test_setPointsGrade_callsSaveGradeWithPointsAsString() {
        viewModel.setPointsGrade(87.5)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "87.5")
    }

    func test_setPercentGrade_callsSaveGradeWithPercentageSign() {
        viewModel.setPercentGrade(87.0)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "87.0%")
    }

    func test_setPercentGrade_callsSaveGradeWithoutRounding() {
        viewModel.setPercentGrade(87.345678)

        XCTAssertTrue(gradeInteractorMock.saveGradeCalled)
        XCTAssertNil(gradeInteractorMock.lastExcused)
        XCTAssertEqual(gradeInteractorMock.lastGrade, "87.345678%")
    }

    // MARK: - Saving State Tests

    func test_saveGrade_setsSavingStateCorrectly() {
        XCTAssertFalse(viewModel.isSavingGrade.value)

        viewModel.setPointsGrade(0)
        XCTAssertTrue(viewModel.isSavingGrade.value)

        gradeInteractorMock.saveGradeSubject.send(completion: .finished)
        XCTAssertFalse(viewModel.isSavingGrade.value)
    }

    func test_saveGradeSuccess_clearsSavingState() {
        viewModel.setPointsGrade(0)
        XCTAssertTrue(viewModel.isSavingGrade.value)

        gradeInteractorMock.saveGradeSubject.send(())
        gradeInteractorMock.saveGradeSubject.send(completion: .finished)

        XCTAssertFalse(viewModel.isSavingGrade.value)
    }

    func test_grade_edited() {
        XCTAssertFalse(viewModel.isGradeChanged)

        gradeInteractorMock.gradeStateSubject.send(
            GradeState.make(originalGradeWithoutMetric: "80")
        )
        XCTAssertFalse(viewModel.isGradeChanged)

        gradeInteractorMock.gradeStateSubject.send(
            GradeState.make(originalGradeWithoutMetric: "20")
        )
        XCTAssertTrue(viewModel.isGradeChanged)
    }

    func test_grade_not_edited() {
        XCTAssertFalse(viewModel.isGradeChanged)

        gradeInteractorMock.gradeStateSubject.send(
            GradeState.make(originalGradeWithoutMetric: "60")
        )
        XCTAssertFalse(viewModel.isGradeChanged)

        gradeInteractorMock.gradeStateSubject.send(
            GradeState.make(originalGradeWithoutMetric: "60")
        )
        XCTAssertFalse(viewModel.isGradeChanged)
    }

    // MARK: - Error Handling Tests

    func test_saveGradeError_showsErrorAlert() {
        XCTAssertFalse(viewModel.isShowingErrorAlert)

        viewModel.setPointsGrade(0)
        gradeInteractorMock.saveGradeSubject.send(completion: .failure(NSError.internalError()))

        XCTAssertEqual(viewModel.isShowingErrorAlert, true)
        XCTAssertEqual(viewModel.errorAlertViewModel.title, "Error")
        XCTAssertEqual(viewModel.errorAlertViewModel.message, "Internal Error")
        XCTAssertEqual(viewModel.errorAlertViewModel.buttonTitle, "OK")
        XCTAssertFalse(viewModel.isSavingGrade.value)
    }

    func test_saveGradeError_clearsIsSavingState() {
        let error = NSError(domain: "TestError", code: 1)

        viewModel.excuseStudent()
        XCTAssertTrue(viewModel.isSavingGrade.value)

        gradeInteractorMock.saveGradeSubject.send(completion: .failure(error))
        XCTAssertFalse(viewModel.isSavingGrade.value)
    }

    // MARK: - No Grade Button Tests

    func test_isNoGradeButtonDisabled_withoutGradeAndNotExcused_isDisabled() {
        let stateWithoutGrade = GradeState.make(
            isGraded: false,
            isExcused: false
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithoutGrade)

        XCTAssertTrue(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withGrade_isEnabled() {
        let stateWithGrade = GradeState.make(
            isGraded: true,
            isExcused: false
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withExcusedGrade_isEnabled() {
        let stateWithExcusedGrade = GradeState.make(
            isGraded: false,
            isExcused: true
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithExcusedGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }

    // MARK: - GradeState Extension Tests

    func test_pointsRowModel_returnsNilForPointsGradingWithoutLateDeduction() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts"
        )

        XCTAssertNil(state.pointsRowModel)
    }

    func test_pointsRowModel_returnsViewModelForPointsGradingWithLateDeduction() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            hasLateDeduction: true,
            score: 85,
            originalScoreWithoutMetric: "95",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "10 pts"
        )

        let result = state.pointsRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.currentPoints, "95")
        XCTAssertEqual(result?.maxPointsWithUnit, "   / 100 pts")
    }

    func test_pointsRowModel_returnsViewModelForNonPointsGrading() {
        let state = GradeState.make(
            gradingType: .percent,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts"
        )

        let result = state.pointsRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.currentPoints, "85")
        XCTAssertEqual(result?.maxPointsWithUnit, "   / 100 pts")
    }

    func test_latePenaltyRowModel_returnsNilWhenNoLateDeduction() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts"
        )

        XCTAssertNil(state.latePenaltyRowModel)
    }

    func test_latePenaltyRowModel_returnsViewModelWhenHasLateDeduction() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            hasLateDeduction: true,
            score: 85,
            originalScoreWithoutMetric: "95",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "-10 pts"
        )

        let result = state.latePenaltyRowModel
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.penaltyText, "-10 pts")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPointsGrading() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            pointsPossibleAccessibilityText: "42 points",
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.gradeText, "85")
        XCTAssertEqual(result.suffixText, "   / 100 pts")
        XCTAssertEqual(result.a11ySuffixText, "out of 42 points")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPercentGrading() {
        let state = GradeState.make(
            gradingType: .percent,
            pointsPossibleText: "100 pts",
            pointsPossibleAccessibilityText: "42 points",
            hasLateDeduction: false,
            score: 85,
            originalScoreWithoutMetric: "85",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "85",
            pointsDeductedText: "0 pts"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.gradeText, "85")
        XCTAssertEqual(result.suffixText, "   %")
        XCTAssertEqual(result.a11ySuffixText, "%")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForLetterGrading() {
        let state = GradeState.make(
            gradingType: .letter_grade,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 87,
            originalScoreWithoutMetric: "87",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "B+",
            pointsDeductedText: "0 pts"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.gradeText, "B+")
        XCTAssertEqual(result.a11yGradeText, "'B' +")
        XCTAssertEqual(result.suffixText, "")
    }

    func test_finalGradeRowModel_returnsCorrectSuffixForPassFailGrading() {
        let state = GradeState.make(
            gradingType: .pass_fail,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 100,
            originalScoreWithoutMetric: "100",
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: "Complete",
            pointsDeductedText: "0 pts"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.gradeText, "Complete")
        XCTAssertEqual(result.suffixText, "")
        XCTAssertEqual(result.a11ySuffixText, nil)
    }

    func test_finalGradeRowModel_handlesNilFinalGradeWithoutMetric() {
        let state = GradeState.make(
            gradingType: .points,
            pointsPossibleText: "100 pts",
            hasLateDeduction: false,
            score: 0,
            originalScoreWithoutMetric: nil,
            originalGradeWithoutMetric: nil,
            finalGradeWithoutMetric: nil,
            pointsDeductedText: "0 pts"
        )

        let result = state.finalGradeRowModel
        XCTAssertEqual(result.gradeText, "-")
        XCTAssertEqual(result.a11yGradeText, "None")
        XCTAssertEqual(result.suffixText, "   / 100 pts")
    }
}
