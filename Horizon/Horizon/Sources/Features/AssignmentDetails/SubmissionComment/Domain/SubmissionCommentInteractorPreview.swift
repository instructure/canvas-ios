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

final class SubmissionCommentInteractorPreview: SubmissionCommentInteractor {
    func getComments(
        context _: Context,
        assignmentID _: String,
        attempt: Int? = nil,
        userID _: String
    ) -> AnyPublisher<[SubmissionComment], any Error> {
        Just([
            SubmissionComment(
                id: "1",
                assignmentID: "1",
                attempt: 1,
                authorID: "1",
                authorName: "Learner",
                comment: "First comment on submission",
                createdAt: Date(),
                isCurrentUsersComment: true
            ),
            SubmissionComment(
                id: "2",
                assignmentID: "1",
                attempt: 1,
                authorID: "2",
                authorName: "Educator",
                comment: "Replying to Learner",
                createdAt: Date(),
                isCurrentUsersComment: false
            ),
            SubmissionComment(
                id: "3",
                assignmentID: "1",
                attempt: 1,
                authorID: "2",
                authorName: "Educator",
                comment: "Replying again",
                createdAt: Date(),
                isCurrentUsersComment: false
            ),
            SubmissionComment(
                id: "4",
                assignmentID: "1",
                attempt: 1,
                authorID: "1",
                authorName: "Learner",
                comment: "Dolor sit amet unc ut lacus ac libero ultrices vestibulum.",
                createdAt: Date(),
                isCurrentUsersComment: true
            ),
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }

    func postComment(_: String) -> AnyPublisher<Void, any Error> {
        Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
