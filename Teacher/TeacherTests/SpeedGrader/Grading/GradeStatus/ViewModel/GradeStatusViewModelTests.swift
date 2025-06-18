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
import Core
import TestsFoundation
@testable import Teacher

class GradeStatusViewModelTests: TeacherTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_init_selectedOption_isNone() {
        let interactor = GradeStatusInteractorMock()
        let viewModel = makeViewModel(interactor: interactor)
        XCTAssertEqual(viewModel.selectedOption.id, "none")
    }

    func test_options_sorted_optionsMatchInteractor() {
        let interactor = GradeStatusInteractorMock()
        interactor.gradeStatuses = [
            GradeStatus(defaultName: "Bravo"),
            GradeStatus(defaultName: "Alpha")
        ]
        let viewModel = makeViewModel(interactor: interactor)
        XCTAssertEqual(viewModel.options.map { $0.title }, ["Alpha", "Bravo"])
    }

    func test_didSelectGradeStatus_triggersUpdateAndSetsSelected() {
        let interactor = GradeStatusInteractorMock()
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let viewModel = makeViewModel(interactor: interactor)
        let option = OptionItem(id: status.id, title: status.name)

        // WHEN
        interactor.updateSubmissionGradeStatusCalled = false
        viewModel.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            interactor.updateSubmissionGradeStatusCalled && viewModel.selectedOption.id == option.id
        }
        XCTAssertTrue(interactor.updateSubmissionGradeStatusCalled)
        XCTAssertEqual(viewModel.selectedOption.id, option.id)
    }

    func test_didChangeAttempt_observeGradeStatusSetsSelectedOption() {
        let interactor = GradeStatusInteractorMock()
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let viewModel = makeViewModel(interactor: interactor)

        // WHEN
        viewModel.didChangeAttempt.send(1)

        // THEN
        waitUntil(shouldFail: true) {
            interactor.observeGradeStatusChangesCalled && viewModel.selectedOption.id == status.id
        }
        XCTAssertTrue(interactor.observeGradeStatusChangesCalled)
        XCTAssertEqual(viewModel.selectedOption.id, status.id)
    }

    func test_didSelectGradeStatus_uploadGradeStatusError_showsAlert() {
        let interactor = GradeStatusInteractorMock()
        interactor.shouldFailUpdateSubmissionGradeStatus = true
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let viewModel = makeViewModel(interactor: interactor)
        let option = OptionItem(id: status.id, title: status.name)

        // WHEN
        viewModel.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            viewModel.isShowingSaveFailedAlert == true && viewModel.isLoading == false
        }
        XCTAssertTrue(viewModel.isShowingSaveFailedAlert)
        XCTAssertFalse(viewModel.isLoading)
    }

    private func makeViewModel(interactor: GradeStatusInteractorMock) -> GradeStatusViewModel {
        GradeStatusViewModel(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            userId: "user1",
            submissionId: "sub1",
            attempt: 1,
            interactor: interactor
        )
    }
}
