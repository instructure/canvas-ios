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

import Foundation

public struct GetHSubmissionCommentsResponse: Codable {
    public let data: DataModel?

    public struct DataModel: Codable {
        public let submission: Submission?
    }

    public struct Submission: Codable {
        public let unreadCommentCount: Int?
        let id: String?
        public let commentsConnection: CommentsConnection?
    }

    public struct CommentsConnection: Codable {
        let pageInfo: PageInfo?
        public let edges: [Edge]?
    }

    public struct Edge: Codable {
        public let node: Comment?
    }

    public struct Comment: Codable {
        public let id: String?
        public let attempt: Int?
        public let author: Author?
        public let comment: String?
        public let read: Bool?
        public let updatedAt, createdAt: Date?
        public let attachments: [Attachment]?
    }

    public struct Author: Codable {
        public let id: String?
        public let avatarURL: String?
        public let shortName: String?
        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case avatarURL = "avatarUrl"
            case shortName
        }
    }

  public struct PageInfo: Codable {
        let endCursor, startCursor: String?
        let hasPreviousPage, hasNextPage: Bool?
    }

    public struct Attachment: Codable {
        let id: String
        let url: String?
        let displayName: String?

        enum CodingKeys: String, CodingKey {
            case id = "_id"
            case url, displayName
        }
    }
}
