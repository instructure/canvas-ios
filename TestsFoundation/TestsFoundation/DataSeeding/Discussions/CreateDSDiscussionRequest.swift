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

import Core

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.create
public struct CreateDSDiscussionRequest: APIRequestable {
    public typealias Response = DSDiscussionTopic

    public let method = APIMethod.post
    public let path: String
    public let body: RequestedDSDiscussion?

    public init(courseID: String, body: RequestedDSDiscussion) {
        self.path = "courses/\(courseID)/discussion_topics"
        self.body = body
    }
}

extension CreateDSDiscussionRequest {
    public struct RequestedDSDiscussion: Encodable {
        let title: String
        let message: String
        let is_announcement: Bool
        let published: Bool
        let assignment: CreateDSAssignmentRequest.RequestedDSAssignment?

        public init(title: String, message: String, is_announcement: Bool = false, published: Bool = true, assignment: CreateDSAssignmentRequest.RequestedDSAssignment? = nil) {
            self.title = title
            self.message = message
            self.is_announcement = is_announcement
            self.published = published
            self.assignment = assignment
        }
    }
}
