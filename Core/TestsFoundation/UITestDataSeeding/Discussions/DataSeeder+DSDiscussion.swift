//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Foundation

extension DataSeeder {

    @discardableResult
    public func createDiscussion(courseId: String, requestBody: CreateDSDiscussionRequest.RequestedDSDiscussion) -> DSDiscussionTopic {
        let request = CreateDSDiscussionRequest(courseID: courseId, body: requestBody)
        return makeRequest(request)
    }

    @discardableResult
    public func createDiscussionWithCheckpoints(
        courseId: String,
        title: String,
        message: String?,
        repliesRequired: Int,
        replyToTopicDueDate: Date?,
        requiredRepliesDueDate: Date?
    ) -> CreateDSDiscussionWithCheckpointsResponse {
        let request = CreateDSDiscussionWithCheckpointsRequest(
            body: .init(
                contextId: courseId,
                title: title,
                message: message,
                assignment: .init(courseId: courseId, name: title),
                checkpoints: [
                    .init(
                        checkpointLabel: "reply_to_topic",
                        pointsPossible: 0,
                        dates: [.init(type: "everyone", dueAt: replyToTopicDueDate)],
                        repliesRequired: repliesRequired
                    ),
                    .init(
                        checkpointLabel: "reply_to_entry",
                        pointsPossible: 0,
                        dates: [.init(type: "everyone", dueAt: requiredRepliesDueDate)],
                        repliesRequired: repliesRequired
                    )
                ]
            )
        )
        return makeRequest(request)
    }
}
