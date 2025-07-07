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
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.selectedOption.id, "none")
    }

    func test_options_sorted_optionsMatchInteractor() {
        let interactor = GradeStatusInteractorMock()
        interactor.gradeStatuses = [
            GradeStatus(defaultStatusId: "Bravo"),
            GradeStatus(defaultStatusId: "Alpha")
        ]
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.options.map { $0.title }, ["Alpha", "Bravo"])
    }

    func test_didSelectGradeStatus_triggersUpdateAndSetsSelected() {
        let interactor = GradeStatusInteractorMock()
        let status = GradeStatus(defaultStatusId: "Alpha")
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
        let interactor = GradeStatusInteractorMock()
        let status = GradeStatus(defaultStatusId: "Alpha")
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
        let interactor = GradeStatusInteractorMock()
        interactor.shouldFailUpdateSubmissionGradeStatus = true
        let status = GradeStatus(defaultStatusId: "Alpha")
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
        let interactor = GradeStatusInteractorMock()
        let statusA = GradeStatus(defaultStatusId: "Alpha")
        let statusNone = GradeStatus(defaultStatusId: "none")
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

    func test_didSelectGradeStatus_hidesNoneOptionTitle() {
        let interactor = GradeStatusInteractorMock()
        interactor.gradeStatuses = [
            GradeStatus(defaultStatusId: "none"),
            GradeStatus(defaultStatusId: "excused")
        ]
        let testee = makeViewModel(interactor: interactor)
        XCTAssertEqual(testee.selectedOption.id, "none")
        XCTAssertEqual(testee.shouldHideSelectedOptionTitle, true)

        // WHEN
        testee.didSelectGradeStatus.send(.init(id: "excused", title: ""))

        // THEN
        waitUntil(shouldFail: true) { testee.selectedOption.id == "excused" }
        XCTAssertEqual(testee.shouldHideSelectedOptionTitle, false)

        // WHEN
        testee.didSelectGradeStatus.send(.init(id: "none", title: ""))

        // THEN
        waitUntil(shouldFail: true) { testee.selectedOption.id == "none" }
        XCTAssertEqual(testee.shouldHideSelectedOptionTitle, true)
    }

    func test_didChangeLateDaysValue_triggersUpdateLateDays() {
        let interactorMock = GradeStatusInteractorMock()
        let testee = makeViewModel(interactor: interactorMock)

        // WHEN
        testee.didChangeLateDaysValue.send(5)

        // THEN
        waitUntil(shouldFail: true) { interactorMock.updateLateDaysCalled }
        XCTAssertTrue(interactorMock.updateLateDaysCalled)
        XCTAssertEqual(interactorMock.updateLateDaysParams?.submissionId, "sub1")
        XCTAssertEqual(interactorMock.updateLateDaysParams?.userId, "user1")
        XCTAssertEqual(interactorMock.updateLateDaysParams?.daysLate, 5)
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
