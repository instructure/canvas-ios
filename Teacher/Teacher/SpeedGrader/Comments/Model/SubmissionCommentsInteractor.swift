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

import Combine
import Core
import Foundation

protocol SubmissionCommentsInteractor: AnyObject {
    func getSubmissionAttempts() -> AnyPublisher<[Submission], Error>
    func getComments() -> AnyPublisher<[SubmissionComment], Error>
    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error>

    func createTextComment(_ text: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void)
    func createMediaComment(type: MediaCommentType, url: URL, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void)
    func createFileComment(batchId: String, attemptNumber: Int?, completion: @escaping (Result<Void, Error>) -> Void)
}

final class SubmissionCommentsInteractorLive: SubmissionCommentsInteractor {

    // MARK: - Private properties

    private let courseId: String
    private let assignmentId: String
    private let submissionUserId: String
    private let isGroupAssignment: Bool

    private let env: AppEnvironment

    private let localSubmissionsStore: ReactiveStore<GetSubmissionAttemptsLocal>
    private let submissionCommentsStore: ReactiveStore<GetSubmissionComments>
    private let featureFlagsStore: ReactiveStore<GetEnabledFeatureFlags>

    // MARK: - Init

    init(
        courseId: String,
        assignmentId: String,
        submissionUserId: String,
        isGroupAssignment: Bool,
        env: AppEnvironment
    ) {
        self.courseId = courseId
        self.assignmentId = assignmentId
        self.submissionUserId = submissionUserId
        self.isGroupAssignment = isGroupAssignment
        self.env = env

        localSubmissionsStore = ReactiveStore(
            useCase: GetSubmissionAttemptsLocal(
                assignmentId: assignmentId,
                userId: submissionUserId
            ),
            environment: env
        )

        submissionCommentsStore = ReactiveStore(
            useCase: GetSubmissionComments(
                context: .course(courseId),
                assignmentID: assignmentId,
                userID: submissionUserId
            ),
            environment: env
        )

        featureFlagsStore = ReactiveStore(
            useCase: GetEnabledFeatureFlags(context: .course(courseId)),
            environment: env
        )
    }

    // MARK: - Get methods

    func getSubmissionAttempts() -> AnyPublisher<[Submission], Error> {
        localSubmissionsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .eraseToAnyPublisher()
    }

    func getComments() -> AnyPublisher<[SubmissionComment], Error> {
        submissionCommentsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .eraseToAnyPublisher()
    }

    func getIsAssignmentEnhancementsEnabled() -> AnyPublisher<Bool, Error> {
        featureFlagsStore
            .getEntities(keepObservingDatabaseChanges: true)
            .map { $0.isFeatureFlagEnabled(.assignmentEnhancements) }
            .eraseToAnyPublisher()
    }

    // MARK: - Create comment

    func createTextComment(
        _ text: String,
        attemptNumber: Int?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // FIXME: Comment is displayed as Sent instantly, regardless of the response.
        //        It was like this before.
        //        Consider displaying it after success only, showing some spinner in the meantime or display the message dimmed until success and roll back if not.
        CreateTextComment(
            env: env,
            courseID: courseId,
            assignmentID: assignmentId,
            userID: submissionUserId,
            isGroup: isGroupAssignment,
            text: text,
            attempt: attemptNumber
        ).fetch { comment, error in
            completion(.init(comment: comment, error: error))
        }
    }

    func createMediaComment(
        type: MediaCommentType,
        url: URL,
        attemptNumber: Int?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        UploadMediaComment(
            env: env,
            courseID: courseId,
            assignmentID: assignmentId,
            userID: submissionUserId,
            isGroup: isGroupAssignment,
            type: type,
            url: url,
            attempt: attemptNumber
        ).fetch { comment, error in
            completion(.init(comment: comment, error: error))
        }
    }

    func createFileComment(
        batchId: String,
        attemptNumber: Int?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        UploadFileComment(
            env: env,
            courseID: courseId,
            assignmentID: assignmentId,
            userID: submissionUserId,
            isGroup: isGroupAssignment,
            batchID: batchId,
            attempt: attemptNumber
        ).fetch { comment, error in
            completion(.init(comment: comment, error: error))
        }
    }
}

private extension Result<Void, Error> {
    init(comment: SubmissionComment?, error: Error?) {
        if let error {
            self = .failure(error)
        } else if comment == nil {
            self = .failure(NSError.instructureError(""))
        } else {
            self = .success
        }
    }
}
