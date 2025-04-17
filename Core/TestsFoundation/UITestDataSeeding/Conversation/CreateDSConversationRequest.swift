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

// https://canvas.instructure.com/doc/api/conversations.html#method.conversations.create
public struct CreateDSConversationRequest: APIRequestable {
    public typealias Response = [DSConversation]

    public let method = APIMethod.post
    public let path: String
    public let body: RequestedDSConversation?

    public init(body: RequestedDSConversation) {
        self.path = "conversations"
        self.body = body
    }
}

extension CreateDSConversationRequest {
    public struct RequestedDSConversation: Encodable {
        let recipients: [String]
        let subject: String
        let body: String
        let context_code: String
        let group_conversation: Bool

        public init(recipients: [String],
                    subject: String,
                    body: String,
                    context_code: String,
                    group_conversation: Bool = false) {
            self.recipients = recipients
            self.subject = subject
            self.body = body
            self.context_code = "course_\(context_code)"
            self.group_conversation = group_conversation
        }
    }
}
