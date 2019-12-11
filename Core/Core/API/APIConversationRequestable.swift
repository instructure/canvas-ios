//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

struct GetConversationsRequest: APIRequestable {
    typealias Response = [APIConversation]
    enum Include: String {
        case participant_avatars
    }
    enum Scope: String {
        case unread, starred, archived, sent
    }

    let path = "conversations"

    let perPage: Int?
    let include: [Include]
    let scope: Scope?

    var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
        ]
        if let perPage = perPage {
            query.append(.value("per_page", String(perPage)))
        }
        if let scope = scope {
            query.append(.value("scope", scope.rawValue))
        }
        return query
    }

    init(include: [Include] = [], perPage: Int? = nil, scope: Scope? = nil) {
        self.include = include
        self.perPage = perPage
        self.scope = scope
    }
}

struct GetConversationRequest: APIRequestable {
    typealias Response = APIConversation
    enum Include: String {
        case participant_avatars
    }

    let id: String
    let include: [Include]
    var path: String { "conversations/\(id)" }
    var query: [APIQueryItem] {
        return [
            .include(include.map { $0.rawValue }),
        ]
    }

    init(id: String, include: [Include] = []) {
        self.id = id
        self.include = include
    }
}

struct PutConversationRequest: APIRequestable {
    typealias Response = APIConversation
    struct Body: Encodable {
        let id: String
        let workflow_state: ConversationWorkflowState
    }

    let id: String
    let workflowState: ConversationWorkflowState
    var path: String { "conversations/\(id)" }
    let method = APIMethod.put
    var body: Body? {
        return Body(id: id, workflow_state: workflowState)
    }
}

struct PostAddMessageRequest: APIRequestable {
    typealias Response = APIConversation
    struct Body: Encodable {
        let recipients: [String]
        let body: String
        let subject: String?
        let attachment_ids: [String]?
        let media_comment_id: String?
        let media_comment_type: MediaCommentType?
        let context_code: String?
        let bulk_message: Int? // nil for group, 1 for send individually
    }

    let id: String
    let message: Body
    var path: String { "conversations/\(id)/add_message" }
    let method = APIMethod.post
}
