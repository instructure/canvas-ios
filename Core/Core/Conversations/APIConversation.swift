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

public enum ConversationWorkflowState: String, Codable {
    case read, unread, archived
}

public enum ConversationProperties: String, Codable {
    case last_author, attachments, media_objects
}

// https://canvas.instructure.com/doc/api/conversations.html#Conversation
public struct APIConversation: Codable, Equatable {
    public let id: ID
    let subject: String?
    let workflow_state: ConversationWorkflowState
    let last_message: String?
    let last_message_at: Date?
    let last_authored_message: String?
    let last_authored_message_at: Date?
    let participants: [APIConversationParticipant]
    let message_count: Int
    let subscribed: Bool
    let `private`: Bool
    let starred: Bool
    let properties: [ConversationProperties]?
    let audience: [ID]?
    let avatar_url: APIURL
    let visible: Bool
    let context_name: String?
    let context_code: String?
    let messages: [APIConversationMessage]?
}

// https://canvas.instructure.com/doc/api/conversations.html#ConversationParticipant
public struct APIConversationParticipant: Codable, Equatable {
    let id: ID
    let name: String
    let avatar_url: APIURL?
    let pronouns: String?
    let common_courses: [String: [String]]?

    public var displayName: String {
        User.displayName(name, pronouns: pronouns)
    }
}

public struct APIConversationMessage: Codable, Equatable {
    let id: ID
    let created_at: Date
    let body: String
    let author_id: ID
    let generated: Bool
    let media_comment: APIMediaComment?
    let attachments: [APIFile]?
    let forwarded_messages: [APIConversationMessage]?
    let participating_user_ids: [ID]?
}

#if DEBUG
extension APIConversation {
    public static func make(
        id: String = "1",
        subject: String = "Subject One",
        workflow_state: ConversationWorkflowState = .unread,
        last_message: String? = "Last Message One",
        last_message_at: Date? = Clock.now,
        last_authored_message: String? = "Last Authored Message One",
        last_authored_message_at: Date? = Clock.now,
        participants: [APIConversationParticipant] = [.make()],
        message_count: Int = 1,
        subscribed: Bool = false,
        private: Bool = false,
        starred: Bool = false,
        properties: [ConversationProperties]? = nil,
        audience: [String]? = [ "1" ],
        avatar_url: URL = UIImage.trashLine.asDataUrl!,
        visible: Bool = true,
        context_name: String? = "Canvas 101",
        context_code: String? = "course_1",
        messages: [APIConversationMessage]? = nil
    ) -> APIConversation {
        return APIConversation(
            id: ID(id),
            subject: subject,
            workflow_state: workflow_state,
            last_message: last_message,
            last_message_at: last_message_at,
            last_authored_message: last_authored_message,
            last_authored_message_at: last_authored_message_at,
            participants: participants,
            message_count: message_count,
            subscribed: subscribed,
            private: `private`,
            starred: starred,
            properties: properties,
            audience: audience?.map { ID($0) },
            avatar_url: APIURL(rawValue: avatar_url),
            visible: visible,
            context_name: context_name,
            context_code: context_code,
            messages: messages
        )
    }
}

extension APIConversationParticipant {
    public static func make(
        id: String = "1",
        name: String = "Participant One",
        avatar_url: URL? = nil,
        pronouns: String? = nil,
        common_courses: [String: [String]]? = nil
    ) -> APIConversationParticipant {
        return APIConversationParticipant(
            id: ID(id),
            name: name,
            avatar_url: APIURL(rawValue: avatar_url),
            pronouns: pronouns,
            common_courses: common_courses
        )
    }
}

extension APIConversationMessage {
    public static func make(
        id: String = "1",
        created_at: Date = Clock.now,
        body: String = "Body One",
        author_id: String = "1",
        generated: Bool = false,
        media_comment: APIMediaComment? = nil,
        attachments: [APIFile]? = nil,
        forwarded_messages: [APIConversationMessage]? = nil,
        participating_user_ids: [ID]? = ["1", "2"]
    ) -> APIConversationMessage {
        return APIConversationMessage(
            id: ID(id),
            created_at: created_at,
            body: body,
            author_id: ID(author_id),
            generated: generated,
            media_comment: media_comment,
            attachments: attachments,
            forwarded_messages: forwarded_messages,
            participating_user_ids: participating_user_ids
        )
    }
}
#endif

public struct GetConversationsUnreadCountRequest: APIRequestable {
    public struct Response: Codable {
        public let unread_count: UInt

        init(unread_count: UInt) {
            self.unread_count = unread_count
        }

        enum CodingKeys: String, CodingKey {
            case unread_count
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            unread_count = try UInt(container.decode(String.self, forKey: .unread_count)) ?? 0
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("\(unread_count)", forKey: .unread_count)
        }
    }

    public let path = "conversations/unread_count"

    public init() {}
}

public struct GetConversationsRequest: APIRequestable {
    public typealias Response = [APIConversation]
    enum Include: String {
        case participant_avatars
    }
    public enum Scope: String {
        case unread, starred, sent, archived
    }

    public let path = "conversations"

    let include: [Include]
    let perPage: Int?
    let scope: Scope?
    let filter: String?

    public var query: [APIQueryItem] {
        var q: [APIQueryItem] = [
            .include(include.map { $0.rawValue }),
            .perPage(perPage),
            .optionalValue("scope", scope?.rawValue),
        ]
        if let filter = filter {
            q.append( .array("filter", [ filter ]) )
        }
        return q
    }
}

public struct GetConversationRequest: APIRequestable {
    public typealias Response = APIConversation
    public enum Include: String {
        case participant_avatars
    }

    let id: String
    let include: [Include]
    public var path: String { "conversations/\(id)" }
    public var query: [APIQueryItem] {
        return [ .include(include.map { $0.rawValue }) ]
    }
}

public struct PutConversationRequest: APIRequestable {
    public typealias Response = APIConversation
    public struct Body: Encodable, Equatable {
        let conversation: ConversationContainer
    }

    let id: String
    let workflowState: ConversationWorkflowState
    public var path: String { "conversations/\(id)" }
    public let method = APIMethod.put

    struct ConversationContainer: Encodable, Equatable {
        let id: String
        let workflow_state: ConversationWorkflowState
    }

    public var body: Body? {
        return Body(conversation: ConversationContainer(id: id, workflow_state: workflowState))
    }
}

public struct StarConversationRequest: APIRequestable {
    public typealias Response = APIConversation
    let id: String
    let starred: Bool
    public var path: String { "conversations/\(id)" }
    public let method = APIMethod.put

    public struct Body: Encodable, Equatable {
        let conversation: ConversationContainer
    }

    struct ConversationContainer: Encodable, Equatable {
        let id: String
        let starred: Bool
    }

    public var body: Body? {
        Body(conversation: ConversationContainer(id: id, starred: starred))
    }
}

public struct PostAddMessageRequest: APIRequestable {
    public typealias Response = APIConversation
    public struct Body: Encodable {
        let attachment_ids: [String]?
        let body: String
        let media_comment_id: String?
        let media_comment_type: MediaCommentType?
        let recipients: [String]?
    }

    let conversationID: String
    public let body: Body?
    public var path: String { "conversations/\(conversationID)/add_message" }
    public let method = APIMethod.post
}

public struct PostConversationRequest: APIRequestable {
    // because it is possible to create one conversation per recipient
    // the response is an array
    public typealias Response = [APIConversation]

    public struct Body: Encodable, Equatable {
        public let subject: String
        public let body: String
        public let recipients: [String]
        public let context_code: String?
        public let media_comment_id: String?
        public let media_comment_type: MediaCommentType?
        public let attachment_ids: [String]?
        public let group_conversation: Bool? = true
        public let force_new: Bool? = nil // Setting this seems to cause the api to ignore group_conversation
    }

    public let body: Body?
    public var path = "conversations"
    public let method = APIMethod.post
}
