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

protocol SubmissionCommentInteractor {
    func getComments(
        assignmentID: String,
        attempt: Int?,
        ignoreCache: Bool
    ) -> AnyPublisher<[SubmissionComment], Error>

    func getComments(
        assignmentID: String,
        ignoreCache: Bool
    ) -> AnyPublisher<[SubmissionComment], Error>

    func postComment(
        courseID: String,
        assignmentID: String,
        attempt: Int?,
        text: String
    ) -> AnyPublisher<Void, Error>

    func getNumberOfComments(
        courseID: String,
        assignmentID: String,
        attempt: Int?
    ) -> AnyPublisher<Int, Error>
}

final class SubmissionCommentInteractorLive: SubmissionCommentInteractor {
    // MARK: - Dependencies

    private let sessionInteractor: SessionInteractor

    // MARK: - Init

    init(sessionInteractor: SessionInteractor) {
        self.sessionInteractor = sessionInteractor
    }

    func getComments(
        assignmentID: String,
        attempt: Int?,
        ignoreCache: Bool
    ) -> AnyPublisher<[SubmissionComment], Error> {
        getComments(assignmentID: assignmentID, ignoreCache: ignoreCache)
            .flatMap { $0.publisher }
            .filter { $0.attempt == attempt || $0.attempt == nil }
            .collect()
            .eraseToAnyPublisher()
    }

    func getNumberOfComments(
        courseID: String,
        assignmentID: String,
        attempt: Int?
    ) -> AnyPublisher<Int, Error> {
        getComments(
            assignmentID: assignmentID,
            attempt: attempt,
            ignoreCache: false
        )
        .map { $0.count }
        .eraseToAnyPublisher()
    }

    func postComment(
        courseID: String,
        assignmentID: String,
        attempt: Int?,
        text: String
    ) -> AnyPublisher<Void, Error> {
        sessionInteractor.getUserID()
            .flatMap { userID in
                ReactiveStore(
                    useCase: PutSubmissionComment(
                        courseID: courseID,
                        assignmentID: assignmentID,
                        userID: userID,
                        text: text,
                        isGroupComment: false,
                        attempt: attempt
                    )
                )
                .getEntities()
                .map { _ in () }
            }
            .eraseToAnyPublisher()
    }

    func getComments(
        assignmentID: String,
        ignoreCache: Bool
    ) -> AnyPublisher<[SubmissionComment], Error> {
        let userID = sessionInteractor.getUserID() ?? ""
        let useCase = GetSubmissionCommentsUseCase(
            userId: userID,
            assignmentId: assignmentID
        )
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .map { entities in
                entities
                    .flatMap { $0.comments }
                    .map {
                        SubmissionComment(
                            from: $0,
                            isCurrentUsersComment: $0.authorID == userID
                        )
                    }
                    .sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            }
            .eraseToAnyPublisher()
    }
}
