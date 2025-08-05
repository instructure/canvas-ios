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
    private var subscriptions: Set<AnyCancellable> = []

    override func tearDown() {
        subscriptions = []
        super.tearDown()
    }

    func test_fetchGradeStatuses_populatesGradeStatuses() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "1", api: api)
        mockGradeStatusesAPI()

        // WHEN
        XCTAssertFinish(testee.fetchGradeStatuses())

        // THEN
        XCTAssertEqual(testee.gradeStatuses.count, 5)
        // Verify sorting: "None" first, then standard statuses in API order, then custom statuses in API order
        XCTAssertEqual(testee.gradeStatuses[0].id, "none")
        XCTAssertEqual(testee.gradeStatuses[1].id, "excused")
        XCTAssertEqual(testee.gradeStatuses[2].id, "late")
        XCTAssertEqual(testee.gradeStatuses[3].id, "custom1")
        XCTAssertEqual(testee.gradeStatuses[4].id, "custom2")

        let custom = testee.gradeStatusFor(
            customGradeStatusId: "custom1",
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertEqual(custom.id, "custom1")

        let excused = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: true,
            isLate: nil
        )
        XCTAssertEqual(excused.id, "excused")

        let late = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: .late,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertEqual(late.id, "late")

        let noStatusGiven = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: nil
        )
        XCTAssertEqual(noStatusGiven, .none)

        let lateByIsLate = testee.gradeStatusFor(
            customGradeStatusId: nil,
            latePolicyStatus: nil,
            isExcused: nil,
            isLate: true
        )
        XCTAssertEqual(lateByIsLate.id, "late")
    }

    func test_observeGradeStatusChanges_emits() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "1", api: api)
        mockGradeStatusesAPI()
        XCTAssertFinish(testee.fetchGradeStatuses())

        let expectation = expectation(description: "observeGradeStatusChanges emits")
        var receivedStatuses: [(GradeStatus, Double, Date?)] = []

        // WHEN
        testee.observeGradeStatusChanges(submissionId: "sub1", attempt: 1)
            .sink { tuple in
                receivedStatuses.append(tuple)
                if receivedStatuses.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &subscriptions)

        let submission = Submission(context: databaseClient)
        submission.id = "sub1"
        submission.attempt = 1
        submission.customGradeStatusId = "custom1"
        submission.latePolicyStatus = nil
        submission.excused = nil
        submission.lateSeconds = 24 * 60 * 60 + 12 * 60 * 60 // 1.5 days (36 hours)
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 1 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = .late
        submission.lateSeconds = 30 * 60 * 60 // 1.25 days (30 hours)
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 2 }

        submission.customGradeStatusId = nil
        submission.latePolicyStatus = nil
        submission.excused = true
        submission.lateSeconds = 18 * 60 * 60 // 0.75 days (18 hours)
        try? databaseClient.save()
        waitUntil(5, shouldFail: true) { receivedStatuses.count == 3 }

        // THEN
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(receivedStatuses.map { $0.0.id }, ["custom1", "late", "excused"])
        XCTAssertEqual(receivedStatuses[0].1, 1.5, accuracy: 0.001)
        XCTAssertEqual(receivedStatuses[1].1, 1.25, accuracy: 0.001)
        XCTAssertEqual(receivedStatuses[2].1, 0.75, accuracy: 0.001)
    }

    func test_updateLateDays_triggersGradeSubmissionUseCase() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "2", api: api)
        let request = GradeSubmission(courseID: "1", assignmentID: "2", userID: "4", lateSeconds: 216000) // 2.5 days * 24 * 60 * 60
        let submission = APISubmission.make(id: "sub1")
        api.mock(request, value: submission)

        // WHEN
        let publisher = testee.updateLateDays(submissionId: "sub1", userId: "4", daysLate: 2.5)

        // THEN
        XCTAssertFinish(publisher)
    }

    func test_fetchGradeStatuses_sortingOrder() {
        let testee = GradeStatusInteractorLive(courseId: "1", assignmentId: "1", api: api)

        // Mock API with mixed order to verify sorting
        let request = GetGradeStatusesRequest(courseID: "1")
        let response = GetGradeStatusesResponse(
            data: .init(
                course: .init(
                    customGradeStatusesConnection: .init(
                        nodes: [
                            .init(name: "ZCustom", id: "zcustom"),
                            .init(name: "ACustom", id: "acustom")
                        ]
                    ),
                    gradeStatuses: ["late", "none", "excused"]
                )
            )
        )
        api.mock(request, value: response)

        // WHEN
        XCTAssertFinish(testee.fetchGradeStatuses())

        // THEN
        XCTAssertEqual(testee.gradeStatuses.count, 5)
        // Verify sorting: "None" first, then remaining defaults in API order, then custom in API order
        XCTAssertEqual(testee.gradeStatuses[0].id, "none")
        XCTAssertEqual(testee.gradeStatuses[1].id, "late")
        XCTAssertEqual(testee.gradeStatuses[2].id, "excused")
        XCTAssertEqual(testee.gradeStatuses[3].id, "zcustom")
        XCTAssertEqual(testee.gradeStatuses[4].id, "acustom")
    }

    private func mockGradeStatusesAPI() {
        let request = GetGradeStatusesRequest(courseID: "1")
        let response = GetGradeStatusesResponse(
            data: .init(
                course: .init(
                    customGradeStatusesConnection: .init(
                        nodes: [
                            .init(name: "Custom1", id: "custom1"),
                            .init(name: "Custom2", id: "custom2")
                        ]
                    ),
                    gradeStatuses: ["excused", "late", "none"]
                )
            )
        )
        api.mock(request, value: response)
    }
}
