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
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "1", api: api)
        mockGradeStatusesAPI()

        // WHEN
        XCTAssertFinish(testee.fetchGradeStatuses())

        // THEN
        XCTAssertEqual(testee.gradeStatuses.count, 4)
        XCTAssertEqual(testee.gradeStatuses[0].id, "excused")
        XCTAssertEqual(testee.gradeStatuses[1].id, "late")
        XCTAssertEqual(testee.gradeStatuses[2].id, "custom1")
        XCTAssertEqual(testee.gradeStatuses[3].id, "custom2")

        let custom = testee.gradeStatusFor(
            customGradeStatusId: "custom1",
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertEqual(custom?.id, "custom1")

        let excused = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: true,
            isLate: nil
        )
        XCTAssertEqual(excused?.id, "excused")

        let late = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: .late,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertEqual(late?.id, "late")

        let notFound = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertNil(notFound)

        let lateByIsLate = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: true
        )
        XCTAssertEqual(lateByIsLate?.id, "late")
    }

    func test_observeGradeStatusChanges_emits() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "1", api: api)
        mockGradeStatusesAPI()
        XCTAssertFinish(testee.fetchGradeStatuses())

        let expectation = expectation(description: "observeGradeStatusChanges emits")
        var receivedStatuses: [(GradeStatus, Int, Date?)] = []

        // WHEN
        testee.observeGradeStatusChanges(submissionId: "sub1", attempt: 1)
            .sink { tuple in
                receivedStatuses.append(tuple)
                if receivedStatuses.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        let submission = Submission(context: databaseClient)
        submission.id = "sub1"
        submission.attempt = 1
        submission.customGradeStatusId = "custom1"
        submission.latePolicyStatus = nil
        submission.excused = nil
        submission.lateSeconds = 24 * 60 * 60
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 1 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = .late
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 2 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = nil
        submission.excused = true
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 3 }

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedStatuses.map { $0.0.id }, ["custom1", "late", "excused"])
        XCTAssertEqual(receivedStatuses.map { $0.1 }, [1, 1, 1])
    }

    func test_updateLateDays_triggersGradeSubmissionUseCase() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "2", api: api)
        let request = GradeSubmission(courseID: "1", assignmentID: "2", userID: "4", lateSeconds: 172800)
        let submission = APISubmission.make(id: "sub1")
        api.mock(request, value: submission)

        // WHEN
        let publisher = testee.updateLateDays(submissionId: "sub1", userId: "4", daysLate: 2)

        // THEN
        XCTAssertFinish(publisher)
    }

    private func mockGradeStatusesAPI() {
        let request = GetGradeStatusesRequest(courseID: "1")
        let response = APIGradeStatuses(
            data: APIGradeStatuses.Data(
                course: APIGradeStatuses.Course(
                    customGradeStatusesConnection: APIGradeStatuses.CustomGradeStatusesConnection(
                        nodes: [
                            APIGradeStatuses.CustomGradeStatus(name: "Custom1", id: "custom1"),
                            APIGradeStatuses.CustomGradeStatus(name: "Custom2", id: "custom2")
                        ]
                    ),
                    gradeStatuses: ["excused", "late"]
                )
            )
        )
        api.mock(request, value: response)
    }
}
