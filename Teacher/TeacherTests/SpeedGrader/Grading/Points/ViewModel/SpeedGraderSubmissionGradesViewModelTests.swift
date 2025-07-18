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
            hasLateDeduction: false,
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            finalGradeText: "85/100",
            gradeText: "85",
            pointsDeductedText: "0 pts",
            gradeAlertText: "85",
            score: 85
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

        XCTAssertEqual(viewModel.state, TestData.sampleGradeState)
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
            hasLateDeduction: false,
            isGraded: false,
            isExcused: false,
            isGradedButNotPosted: false,
            finalGradeText: "",
            gradeText: "",
            pointsDeductedText: "",
            gradeAlertText: "",
            score: 0
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithoutGrade)

        XCTAssertTrue(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withGrade_isEnabled() {
        let stateWithGrade = GradeState(
            hasLateDeduction: false,
            isGraded: true,
            isExcused: false,
            isGradedButNotPosted: false,
            finalGradeText: "85/100",
            gradeText: "85",
            pointsDeductedText: "",
            gradeAlertText: "85",
            score: 85
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }

    func test_isNoGradeButtonDisabled_withExcusedGrade_isEnabled() {
        let stateWithExcusedGrade = GradeState(
            hasLateDeduction: false,
            isGraded: false,
            isExcused: true,
            isGradedButNotPosted: false,
            finalGradeText: "Excused",
            gradeText: "",
            pointsDeductedText: "",
            gradeAlertText: "Excused",
            score: 0
        )

        gradeInteractorMock.gradeStateSubject.send(stateWithExcusedGrade)

        XCTAssertFalse(viewModel.isNoGradeButtonDisabled)
    }
}
