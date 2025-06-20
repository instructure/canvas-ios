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
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.selectedOption.id, "none")
    }

    func test_options_sorted_optionsMatchInteractor() {
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        interactor.gradeStatuses = [
            GradeStatus(defaultName: "Bravo"),
            GradeStatus(defaultName: "Alpha")
        ]
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.options.map { $0.title }, ["Alpha", "Bravo"])
    }

    func test_didSelectGradeStatus_triggersUpdateAndSetsSelected() {
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let testee = makeViewModel(interactor: interactor)
        let option = OptionItem(id: status.id, title: status.name)

        // WHEN
        interactor.updateSubmissionGradeStatusCalled = false
        testee.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            interactor.updateSubmissionGradeStatusCalled && testee.selectedOption.id == option.id
        }
        XCTAssertEqual(interactor.updateSubmissionGradeStatusCalled, true)
        XCTAssertEqual(testee.selectedOption.id, option.id)
    }

    func test_didChangeAttempt_observeGradeStatusSetsSelectedOption() {
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let testee = makeViewModel(interactor: interactor)

        // WHEN
        testee.didChangeAttempt.send(1)

        // THEN
        waitUntil(shouldFail: true) {
            interactor.observeGradeStatusChangesCalled && testee.selectedOption.id == status.id
        }
        XCTAssertEqual(interactor.observeGradeStatusChangesCalled, true)
        XCTAssertEqual(testee.selectedOption.id, status.id)
    }

    func test_didSelectGradeStatus_uploadGradeStatusError_showsAlert() {
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        interactor.shouldFailUpdateSubmissionGradeStatus = true
        let status = GradeStatus(defaultName: "Alpha")
        interactor.gradeStatuses = [status]
        let testee = makeViewModel(interactor: interactor)
        let option = OptionItem(id: status.id, title: status.name)

        // WHEN
        testee.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            testee.isShowingSaveFailedAlert == true && testee.isLoading == false
        }
        XCTAssertEqual(testee.isShowingSaveFailedAlert, true)
        XCTAssertEqual(testee.isLoading, false)
    }

    func test_didSelectGradeStatus_retryUpload_succeedsAfterFailure() {
        let interactor = GradeStatusInteractorMock(submissionId: "subId", userId: "userId", assignmentId: "assignmentId")
        let statusA = GradeStatus(defaultName: "Alpha")
        let statusNone = GradeStatus(defaultName: "none")
        interactor.gradeStatuses = [statusNone, statusA]
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.selectedOption.id, "none")
        let option = OptionItem(id: statusA.id, title: statusA.name)

        // WHEN
        interactor.shouldFailUpdateSubmissionGradeStatus = true
        testee.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            testee.isShowingSaveFailedAlert == true
        }
        XCTAssertEqual(testee.isLoading, false)
        XCTAssertEqual(testee.selectedOption.id, "none")

        // WHEN
        interactor.shouldFailUpdateSubmissionGradeStatus = false
        testee.isShowingSaveFailedAlert = false
        testee.didSelectGradeStatus.send(option)

        // THEN
        waitUntil(shouldFail: true) {
            testee.selectedOption.id == option.id && testee.isLoading == false
        }
    }

    private func makeViewModel(interactor: GradeStatusInteractorMock) -> GradeStatusViewModel {
        GradeStatusViewModel(
            userId: "user1",
            submissionId: "sub1",
            attempt: 1,
            interactor: interactor
        )
    }
}
