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
@testable import Core
import Combine
@testable import Teacher
import TestsFoundation

class GradeStatusInteractorTests: TeacherTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables = []
        super.tearDown()
    }

    func test_fetchGradeStatuses_populatesGradeStatuses() {
        let interactor = GradeStatusInteractorLive(courseId: "1", api: api)
        mockGradeStatusesAPI()

        // WHEN
        XCTAssertFinish(interactor.fetchGradeStatuses())

        // THEN
        XCTAssertEqual(interactor.gradeStatuses.count, 4)
        XCTAssertEqual(interactor.gradeStatuses[0].id, "excused")
        XCTAssertEqual(interactor.gradeStatuses[1].id, "late")
        XCTAssertEqual(interactor.gradeStatuses[2].id, "custom1")
        XCTAssertEqual(interactor.gradeStatuses[3].id, "custom2")

        let custom = interactor.gradeStatusFor(
            customGradeStatusId: "custom1",
            latePolicyStatus: nil,
            isExcused: nil
        )
        XCTAssertEqual(custom?.id, "custom1")

        let excused = interactor.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: true
        )
        XCTAssertEqual(excused?.id, "excused")

        let late = interactor.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: .late,
            isExcused: nil
        )
        XCTAssertEqual(late?.id, "late")

        let notFound = interactor.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: nil
        )
        XCTAssertNil(notFound)
    }

    func test_updateSubmissionGradeStatus_triggersRefresh() {
        let interactor = GradeStatusInteractorLive(courseId: "1", api: api)
        let speedGraderMock = SpeedGraderInteractorMock()
        interactor.speedGraderInteractor = speedGraderMock
        let request = UpdateSubmissionGradeStatusRequest(submissionId: "sub1", customGradeStatusId: "custom1", latePolicyStatus: nil)
        api.mock(request, value: APINoContent())

        // WHEN
        XCTAssertFinish(interactor.updateSubmissionGradeStatus(
            submissionId: "sub1",
            userId: "user1",
            customGradeStatusId: "custom1",
            latePolicyStatus: nil
        ))

        // THEN
        XCTAssertEqual(speedGraderMock.isRefreshSubmissionCalled, true)
    }

    func test_observeGradeStatusChanges_emits() {
        let interactor = GradeStatusInteractorLive(courseId: "1", api: api)
        mockGradeStatusesAPI()
        XCTAssertFinish(interactor.fetchGradeStatuses())

        let expectation = expectation(description: "observeGradeStatusChanges emits")
        var receivedStatuses: [GradeStatus?] = []

        // WHEN
        interactor.observeGradeStatusChanges(submissionId: "sub1", attempt: 1)
            .sink { status in
                receivedStatuses.append(status)
                if receivedStatuses.count == 4 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        waitUntil(5, shouldFail: true) { receivedStatuses.count == 1 }
        let submission = Submission(context: databaseClient)
        submission.id = "sub1"
        submission.attempt = 1
        submission.customGradeStatusId = "custom1"
        submission.latePolicyStatus = nil
        submission.excused = nil
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 2 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = .late
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 3 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = nil
        submission.excused = true
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 4 }

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedStatuses.map { $0?.id }, [nil, "custom1", "late", "excused"])
    }

    private func mockGradeStatusesAPI() {
        let request = GetGradeStatusesRequest(courseID: "1")
        let response = APIGradeStatuses(
            data: APIGradeStatuses.Data(
                course: APIGradeStatuses.Course(
                    customGradeStatusesConnection: APIGradeStatuses.CustomGradeStatusesConnection(
                        nodes: [
                            APIGradeStatuses.CustomGradeStatus(color: "#FF0000", name: "Custom1", id: "custom1"),
                            APIGradeStatuses.CustomGradeStatus(color: "#00FF00", name: "Custom2", id: "custom2")
                        ]
                    ),
                    gradeStatuses: ["excused", "late"]
                )
            )
        )
        api.mock(request, value: response)
    }
}
