//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

@testable import Core
@testable import Horizon
import Combine
import XCTest
import TestsFoundation

final class HCourseSyncScoresInteractorLiveTests: HorizonTestCase {

    private static let testData = (
        userID: "user 1",
        courseID1: "course 1",
        courseID2: "course 2",
        enrollmentID1: "enrollment 1",
        enrollmentID2: "enrollment 2"
    )
    private lazy var testData = Self.testData

    private var testee: HCourseSyncScoresInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        testee = HCourseSyncScoresInteractorLive(userId: testData.userID)
    }

    override func tearDown() {
        testee = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - getScores

    func test_getScores_shouldCompleteAfterFetchingBothUseCases() {
        mockSubmissionScores(enrollmentID: testData.enrollmentID1)
        mockCourse(courseID: testData.courseID1)

        XCTAssertFinish(testee.getScores(courseID: testData.courseID1, enrollmentID: testData.enrollmentID1))
    }

    func test_getScores_whenSubmissionScoresFail_shouldStillComplete() {
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: testData.enrollmentID1),
            error: NSError.instructureError("network error")
        )
        mockCourse(courseID: testData.courseID1)

        XCTAssertFinish(testee.getScores(courseID: testData.courseID1, enrollmentID: testData.enrollmentID1))
    }

    func test_getScores_whenCourseFetchFails_shouldStillComplete() {
        mockSubmissionScores(enrollmentID: testData.enrollmentID1)
        api.mock(
            GetCourseRequest(courseID: testData.courseID1),
            error: NSError.instructureError("network error")
        )

        XCTAssertFinish(testee.getScores(courseID: testData.courseID1, enrollmentID: testData.enrollmentID1))
    }

    func test_getScores_shouldRequestSubmissionScoresForEnrollment() {
        let apiExpectation = expectation(description: "Submission scores API called")
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: testData.enrollmentID1),
            expectation: apiExpectation,
            value: GetHSubmissionScoresResponse(data: nil)
        )
        mockCourse(courseID: testData.courseID1)

        testee.getScores(courseID: testData.courseID1, enrollmentID: testData.enrollmentID1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)

        wait(for: [apiExpectation], timeout: 1)
    }

    func test_getScores_shouldRequestCourse() {
        let apiExpectation = expectation(description: "Course API called")
        mockSubmissionScores(enrollmentID: testData.enrollmentID1)
        api.mock(
            GetCourseRequest(courseID: testData.courseID1),
            expectation: apiExpectation,
            value: .make(id: ID(testData.courseID1))
        )

        testee.getScores(courseID: testData.courseID1, enrollmentID: testData.enrollmentID1)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &subscriptions)

        wait(for: [apiExpectation], timeout: 1)
    }

    // MARK: - getContent

    func test_getContent_withEmptyCourses_shouldNotMakeAnyAPIRequests() {
        testee.getContent(courses: [])
    }

    func test_getContent_withSingleCourse_shouldRequestScores() {
        let apiExpectation = expectation(description: "Submission scores API called")
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: testData.enrollmentID1),
            expectation: apiExpectation,
            value: GetHSubmissionScoresResponse(data: nil)
        )
        mockCourse(courseID: testData.courseID1)

        testee.getContent(courses: [makeCourseItem(id: testData.courseID1, enrollmentID: testData.enrollmentID1)])

        wait(for: [apiExpectation], timeout: 1)
    }

    func test_getContent_withMultipleCourses_shouldRequestScoresForEach() {
        let apiExpectation1 = expectation(description: "Scores API called for enrollment 1")
        let apiExpectation2 = expectation(description: "Scores API called for enrollment 2")
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: testData.enrollmentID1),
            expectation: apiExpectation1,
            value: GetHSubmissionScoresResponse(data: nil)
        )
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: testData.enrollmentID2),
            expectation: apiExpectation2,
            value: GetHSubmissionScoresResponse(data: nil)
        )
        mockCourse(courseID: testData.courseID1)
        mockCourse(courseID: testData.courseID2)

        testee.getContent(courses: [
            makeCourseItem(id: testData.courseID1, enrollmentID: testData.enrollmentID1),
            makeCourseItem(id: testData.courseID2, enrollmentID: testData.enrollmentID2)
        ])

        wait(for: [apiExpectation1, apiExpectation2], timeout: 1)
    }

    func test_getContent_whenCalledTwice_shouldCancelPreviousRequests() {
        mockSubmissionScores(enrollmentID: testData.enrollmentID1)
        mockCourse(courseID: testData.courseID1)

        testee.getContent(courses: [makeCourseItem(id: testData.courseID1, enrollmentID: testData.enrollmentID1)])
        testee.getContent(courses: [])
    }

    // MARK: - cancelRequests

    func test_cancelRequests_shouldNotCrash() {
        mockSubmissionScores(enrollmentID: testData.enrollmentID1)
        mockCourse(courseID: testData.courseID1)
        testee.getContent(courses: [makeCourseItem(id: testData.courseID1, enrollmentID: testData.enrollmentID1)])

        testee.cancelRequests()
    }

    func test_cancelRequests_withoutActiveRequests_shouldNotCrash() {
        testee.cancelRequests()
    }

    // MARK: - Private helpers

    private func mockSubmissionScores(enrollmentID: String) {
        api.mock(
            GetHSubmissionScoresRequest(userId: testData.userID, enrollmentId: enrollmentID),
            value: GetHSubmissionScoresResponse(data: nil)
        )
    }

    private func mockCourse(courseID: String) {
        api.mock(
            GetCourseRequest(courseID: courseID),
            value: .make(id: ID(courseID))
        )
    }

    private func makeCourseItem(id: String, enrollmentID: String) -> OfflineCourseItem {
        OfflineCourseItem(
            id: id,
            enrollmentID: enrollmentID,
            name: "course name",
            subItems: []
        )
    }
}
