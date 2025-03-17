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
        courseID: String,
        assignmentID: String,
        attempt: Int?
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
        courseID: String,
        assignmentID: String,
        attempt: Int?
    ) -> AnyPublisher<[SubmissionComment], Error> {
        sessionInteractor.getUserID()
            .flatMap { userID in
                ReactiveStore(
                    useCase: GetSubmissionComments(
                        context: .course(courseID),
                        assignmentID: assignmentID,
                        userID: userID,
                        isAscendingOrder: true
                    )
                )
                .getEntities()
                .flatMap { $0.publisher }
                // TODO: Remove $0.mediaURL == nil once media comments like audio, video, image is supported
                .filter { ($0.attemptFromAPI == nil || $0.attemptFromAPI?.intValue == attempt) && $0.mediaURL == nil && !$0.id.contains("submission") }
                .map { SubmissionComment(from: $0, isCurrentUsersComment: $0.authorID?.localID == userID) }
                .collect()
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func getNumberOfComments(
        courseID: String,
        assignmentID: String,
        attempt: Int?
    ) -> AnyPublisher<Int, Error> {
        getComments(
            courseID: courseID,
            assignmentID: assignmentID,
            attempt: attempt
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
}
