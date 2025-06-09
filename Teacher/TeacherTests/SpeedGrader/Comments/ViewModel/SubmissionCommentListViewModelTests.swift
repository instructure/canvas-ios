//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Combine
import SwiftUI
@testable import Teacher
import TestsFoundation
import XCTest

class SubmissionCommentListViewModelTests: TeacherTestCase {

    private enum TestConstants {
        static let assignmentId = "some assignmentId"
        static let courseId = "some courseId"
        static let submissionId = "some submissionId"
        static let submissionUserId = "some submissionUserId"
        static let currentUserId = "some currentUserId"
    }

    private var assignment: Assignment!
    private var submission: Submission!
    private var interactor: SubmissionCommentsInteractorMock!

    override func setUp() {
        super.setUp()

        assignment = Assignment(context: databaseClient)
        assignment.id = TestConstants.assignmentId
        assignment.courseID = TestConstants.courseId

        submission = Submission(context: databaseClient)
        submission.id = TestConstants.submissionId
        submission.userID = TestConstants.submissionUserId

        interactor = .init()
    }

    override func tearDown() {
        assignment = nil
        submission = nil
        interactor = nil
        super.tearDown()
    }

    // MARK: - state

    func test_state_whenValueIsNotReturned_shouldBeLoading() {
        interactor.getCommentsResult = Publishers.typedJust([])
            .delay(for: .seconds(1), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .loading)
    }

    func test_state_whenGetSubmissionsFails_shouldBeError() {
        interactor.getSubmissionAttemptsResult = Publishers.typedFailure(error: MockError())

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .error)
    }

    func test_state_whenGetCommentsFails_shouldBeError() {
        interactor.getCommentsResult = Publishers.typedFailure(error: MockError())

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .error)
    }

    func test_state_whenGetFeatureFlagFails_shouldBeError() {
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedFailure(error: MockError())

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .error)
    }

    func test_state_whenThereAreNoComments_shouldBeEmpty() {
        interactor.getSubmissionAttemptsResult = Publishers.typedJust([submission])
        interactor.getCommentsResult = Publishers.typedJust([])
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .empty)
    }

    func test_state_whenThereAreComments_shouldBeData() {
        interactor.getSubmissionAttemptsResult = Publishers.typedJust([])
        interactor.getCommentsResult = Publishers.typedJust([SubmissionComment(context: databaseClient)])

        let testee = makeViewModel()

        XCTAssertEqual(testee.state, .data)
    }

    // MARK: - contextColor

    func test_contextColor() {
        let publisher = PassthroughSubject<Color, Never>()

        let testee = makeViewModel(contextColor: publisher.eraseToAnyPublisher())
        XCTAssertEqual(testee.contextColor.hexString, Brand.shared.primary.hexString)

        publisher.send(.green)
        XCTAssertEqual(testee.contextColor.hexString, Color.green.hexString)
    }

    // MARK: - filtering

    func test_cellViewModels_whenAssignmentEnhancementsIsEnabled_shouldBeFiltered() throws {
        interactor.getCommentsResult = Publishers.typedJust([
            makeComment(id: "0", attempt: nil),
            makeComment(id: "1", attempt: 1),
            makeComment(id: "2", attempt: 2),
            makeComment(id: "3", attempt: nil)
        ])
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)

        let testee = makeViewModel(latestAttemptNumber: 2)

        guard testee.cellViewModels.count == 3 else { throw InvalidCountError() }
        XCTAssertEqual(testee.cellViewModels[0].id, "0")
        XCTAssertEqual(testee.cellViewModels[1].id, "2")
        XCTAssertEqual(testee.cellViewModels[2].id, "3")
    }

    func test_cellViewModels_whenAssignmentEnhancementsIsDisabled_shouldNotBeFiltered() throws {
        interactor.getCommentsResult = Publishers.typedJust([
            makeComment(id: "0", attempt: nil),
            makeComment(id: "1", attempt: 1),
            makeComment(id: "2", attempt: 2),
            makeComment(id: "3", attempt: nil)
        ])
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(false)

        let testee = makeViewModel(latestAttemptNumber: 2)

        guard testee.cellViewModels.count == 4 else { throw InvalidCountError() }
        XCTAssertEqual(testee.cellViewModels[0].id, "0")
        XCTAssertEqual(testee.cellViewModels[1].id, "1")
        XCTAssertEqual(testee.cellViewModels[2].id, "2")
        XCTAssertEqual(testee.cellViewModels[3].id, "3")
    }

    // MARK: - cellViewModels

    func test_cellViewModels_shouldUseTheCorrectSubmission() throws {
        interactor.getSubmissionAttemptsResult = Publishers.typedJust([
            makeSubmission(id: "sub2", attempt: 2),
            makeSubmission(id: "sub1", attempt: 1)
        ])
        interactor.getCommentsResult = Publishers.typedJust([
            // `id` follows specific format to make the commentType `attempt`, to allow spying on `submission`
            makeComment(id: "x-x-1", attempt: 1),
            makeComment(id: "x-x-2", attempt: 2)
        ])

        let testee = makeViewModel(latestAttemptNumber: 2)

        guard testee.cellViewModels.count == 2 else { throw InvalidCountError() }
        guard case let .attempt(attempt0, submission0) = testee.cellViewModels[0].commentType,
              case let .attempt(attempt1, submission1) = testee.cellViewModels[1].commentType
        else {
            return XCTFail("Unexpected comment type")
        }
        XCTAssertEqual(attempt0, 1)
        XCTAssertEqual(submission0.id, "sub1")
        XCTAssertEqual(attempt1, 2)
        XCTAssertEqual(submission1.id, "sub2")
    }

    // MARK: - Attempt change

    func test_cellViewModels_whenAttemptIsChanged_shouldUpdateFiltering() throws {
        interactor.getCommentsResult = Publishers.typedJust([
            makeComment(id: "1", attempt: 1),
            makeComment(id: "2", attempt: 2)
        ])
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)
        let testee = makeViewModel(latestAttemptNumber: 2)

        NotificationCenter.default.post(
            name: .SpeedGraderAttemptPickerChanged,
            object: SpeedGraderAttemptChangeInfo(attemptIndex: 3, userId: TestConstants.submissionUserId)
        )
        XCTAssertEqual(testee.state, .empty)
        XCTAssertEqual(testee.cellViewModels.count, 0)

        NotificationCenter.default.post(
            name: .SpeedGraderAttemptPickerChanged,
            object: SpeedGraderAttemptChangeInfo(attemptIndex: 1, userId: TestConstants.submissionUserId)
        )
        XCTAssertEqual(testee.state, .data)
        guard testee.cellViewModels.count == 1 else { throw InvalidCountError() }
        XCTAssertEqual(testee.cellViewModels[0].id, "1")
    }

    // MARK: - Send comment

    func test_attemptNumber_whenAssignmentEnhancementsIsEnabled_shouldBeUsedForNewComment() {
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)
        let testee = makeViewModel(latestAttemptNumber: 42)

        testee.sendTextComment("") { _ in }

        XCTAssertEqual(interactor.createTextCommentInput?.attemptNumber, 42)
    }

    func test_attemptNumber_whenAssignmentEnhancementsIsDisabled_shouldNotBeUsedForNewComment() {
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(false)
        let testee = makeViewModel(latestAttemptNumber: 42)

        testee.sendTextComment("") { _ in }

        XCTAssertEqual(interactor.createTextCommentInput?.attemptNumber, nil)
    }

    func test_sendTextComment() {
        var result: Result<String, Error>?
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)
        let testee = makeViewModel(latestAttemptNumber: 42)

        testee.sendTextComment("some comment") { result = $0 }

        XCTAssertEqual(interactor.createTextCommentCallsCount, 1)
        XCTAssertEqual(interactor.createTextCommentInput?.text, "some comment")
        XCTAssertEqual(interactor.createTextCommentInput?.attemptNumber, 42)
        verifySendCommentCompletion(interactor.createTextCommentInput?.completion, result: { result })
    }

    func test_sendMediaComment() {
        var result: Result<String, Error>?
        let url = URL(string: "/some/url")!
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)
        let testee = makeViewModel(latestAttemptNumber: 42)

        testee.sendMediaComment(type: .video, url: url) { result = $0 }

        XCTAssertEqual(interactor.createMediaCommentCallsCount, 1)
        XCTAssertEqual(interactor.createMediaCommentInput?.type, .video)
        XCTAssertEqual(interactor.createMediaCommentInput?.url, url)
        XCTAssertEqual(interactor.createMediaCommentInput?.attemptNumber, 42)
        verifySendCommentCompletion(interactor.createMediaCommentInput?.completion, result: { result })
    }

    func test_sendFileComment() {
        var result: Result<String, Error>?
        interactor.getIsAssignmentEnhancementsEnabledResult = Publishers.typedJust(true)
        let testee = makeViewModel(latestAttemptNumber: 42)

        testee.sendFileComment(batchId: "some id") { result = $0 }

        XCTAssertEqual(interactor.createFileCommentCallsCount, 1)
        XCTAssertEqual(interactor.createFileCommentInput?.batchId, "some id")
        XCTAssertEqual(interactor.createFileCommentInput?.attemptNumber, 42)
        verifySendCommentCompletion(interactor.createFileCommentInput?.completion, result: { result })
    }

    private func verifySendCommentCompletion(
        _ completion: ((Result<Void, Error>) -> Void)?,
        result: @escaping () -> Result<String, Error>?
    ) {
        guard let completion else { return XCTFail("Input has no value") }

        // success should have success message
        completion(.success)
        XCTAssertEqual(result()?.value, String(localized: "Comment sent successfully", bundle: .teacher))

        // failure should have error message if the error has any
        completion(.failure(MockError(message: "some error")))
        XCTAssertEqual(result()?.error?.localizedDescription, "some error")

        // failure should have generic error message if the error has none
        completion(.failure(MockError()))
        XCTAssertEqual(result()?.error?.localizedDescription, String(localized: "Could not save the comment.", bundle: .teacher))
    }

    // MARK: - Private helpers

    private func makeViewModel(
        latestAttemptNumber: Int? = nil,
        currentUserId: String? = TestConstants.currentUserId,
        contextColor: AnyPublisher<Color, Never> = Publishers.typedEmpty()
    ) -> SubmissionCommentListViewModel {
        SubmissionCommentListViewModel(
            assignment: assignment,
            latestSubmission: submission,
            latestAttemptNumber: latestAttemptNumber,
            currentUserId: currentUserId,
            contextColor: contextColor,
            interactor: interactor,
            scheduler: .immediate,
            env: environment
        )
    }

    private func makeComment(
        id: String = "",
        attempt: Int? = nil,
        assignmentId: String = TestConstants.assignmentId,
        submissionUserId: String = TestConstants.submissionUserId
    ) -> SubmissionComment {
        SubmissionComment.save(
            .make(id: id, attempt: attempt),
            for: .make(
                assignment_id: .init(assignmentId),
                user_id: .init(submissionUserId)
            ),
            in: databaseClient
        )
    }

    private func makeSubmission(
        id: String = "",
        attempt: Int? = nil
    ) -> Submission {
        Submission.save(
            .make(attempt: attempt, id: .init(id)),
            in: databaseClient
        )
    }
}

private final class SubmissionCommentsInteractorMock: SubmissionCommentsInteractor {

    // MARK: - getSubmissionAttempts

    var getSubmissionAttemptsCallsCount: Int = 0
    var getSubmissionAttemptsResult: AnyPublisher<[Submission], Error>?
    func getSubmissionAttempts() -> AnyPublisher<[Submission], Error> {
        getSubmissionAttemptsCallsCount += 1
        return getSubmissionAttemptsResult ?? Publishers.typedJust([])
    }

    // MARK: - getComments

    var getCommentsCallsCount: Int = 0
    var getCommentsResult: AnyPublisher<[SubmissionComment], Error>?
    func getComments() -> AnyPublisher<[SubmissionComment], Error> {
        getCommentsCallsCount += 1
        return getCommentsResult ?? Publishers.typedJust([])
    }

    // MARK: - getIsAssignmentEnhancementsEnabled

    var getIsAssignmentEnhancementsEnabledCallsCount: Int = 0
    var getIsAssignmentEnhancementsEnabledResult: AnyPublisher<Bool, Error>?
    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error> {
        getIsAssignmentEnhancementsEnabledCallsCount += 1
        return getIsAssignmentEnhancementsEnabledResult ?? Publishers.typedJust(false)
    }

    // MARK: - createTextComment

    var createTextCommentCallsCount: Int = 0
    var createTextCommentInput: (text: String, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createTextComment(_ text: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createTextCommentCallsCount += 1
        createTextCommentInput = (text: text, attemptNumber: attemptNumber, completion: completion)
    }

    // MARK: - createMediaComment

    var createMediaCommentCallsCount: Int = 0
    var createMediaCommentInput: (type: MediaCommentType, url: URL, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createMediaComment(type: MediaCommentType, url: URL, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createMediaCommentCallsCount += 1
        createMediaCommentInput = (type: type, url: url, attemptNumber: attemptNumber, completion: completion)
    }

    // MARK: - createFileComment

    var createFileCommentCallsCount: Int = 0
    var createFileCommentInput: (batchId: String, attemptNumber: Int?, completion: (Result<Void, Error>) -> Void)?
    func createFileComment(batchId: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void) {
        createFileCommentCallsCount += 1
        createFileCommentInput = (batchId: batchId, attemptNumber: attemptNumber, completion: completion)
    }
}
