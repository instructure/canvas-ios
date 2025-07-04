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
        attempt: Int,
        ignoreCache: Bool,
        beforeCursor: String?,
        last: Int?
    ) -> AnyPublisher<[SubmissionComment], Error>

    func postComment(
        courseID: String,
        assignmentID: String,
        attempt: Int?,
        text: String
    ) -> AnyPublisher<Void, Error>
}

final class SubmissionCommentInteractorLive: SubmissionCommentInteractor {
    // MARK: - Dependencies

    private let sessionInteractor: SessionInteractor

    // MARK: - Init

    init(sessionInteractor: SessionInteractor) {
        self.sessionInteractor = sessionInteractor
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
        attempt: Int,
        ignoreCache: Bool,
        beforeCursor: String?,
        last: Int?
    ) -> AnyPublisher<[SubmissionComment], Error> {
        let userID = sessionInteractor.getUserID() ?? ""

        let useCase = GetHSubmissionCommentsUseCase(
            userId: userID,
            assignmentId: assignmentID,
            forAttempt: attempt,
            beforeCursor: beforeCursor,
            last: last
        )

        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .map { entities in
                let firstComment = entities.last
                let comments = entities.flatMap { $0.comments }
                return comments.map { comment in
                    SubmissionComment(
                        from: comment,
                        isCurrentUsersComment: comment.authorID == userID,
                        hasNextPage: firstComment?.hasNextPage ?? false,
                        hasPreviousPage: firstComment?.hasPreviousPage ?? false,
                        startCursor: firstComment?.startCursor
                    )
                }
                .sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            }
            .eraseToAnyPublisher()
    }
}
