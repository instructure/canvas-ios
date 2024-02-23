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

import Core

public struct UpdateDSConversationRequest: APIRequestable {
    public typealias Response = DSProgress

    public let method = APIMethod.put
    public let path: String
    public let body: Body?

    public init(body: Body) {
        self.body = body
        self.path = "conversations"
    }
}

extension UpdateDSConversationRequest {
    public struct Body: Encodable {
        let conversation_ids: [String]
        let event: String

        public init(conversation_ids: [String], event: DSEvent) {
            self.conversation_ids = conversation_ids
            self.event = event.rawValue
        }
    }
}

public struct GetDSProgressRequest: APIRequestable {
    public typealias Response = DSProgress

    public let method = APIMethod.get
    public let path: String

    public init(progressId: String) {
        self.path = "progress/\(progressId)"
    }
}

public enum DSEvent: String {
    case markAsRead = "mark_as_read"
    case markAsUnread = "mark_as_unread"
    case markAsStarred = "star"
    case markAsUnstarred = "unstar"
    case markAsArchived = "archive"
    case markAsDestroyed = "destroy"
}
