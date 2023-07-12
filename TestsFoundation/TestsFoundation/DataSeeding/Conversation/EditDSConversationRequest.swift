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

public struct EditDSConversationRequest: APIRequestable {
    public typealias Response = DSConversation

    public let method = APIMethod.put
    public let path: String
    public let body: Body?

    public init(body: Body, conversationId: String) {
        self.body = body
        self.path = "conversations/\(conversationId)"
    }
}

extension EditDSConversationRequest {
    public struct Conversation: Encodable {
        let workflow_state: String

        public init(workflow_state: DSWorkFlowState) {
            self.workflow_state = workflow_state.rawValue
        }
    }

    public struct Body: Encodable {
        let conversation: Conversation
        let scope: String

        public init(conversation: Conversation, scope: DSScope) {
            self.conversation = conversation
            self.scope = scope.rawValue
        }
    }
}

public enum DSWorkFlowState: String {
    case read
    case unread
    case archived
}

public enum DSScope: String {
    case unread
    case starred
    case archived
}
