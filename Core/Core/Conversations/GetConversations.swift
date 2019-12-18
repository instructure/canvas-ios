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

public class GetConversations: CollectionUseCase {
    public typealias Model = Conversation
    let include: [GetConversationsRequest.Include] = [.participant_avatars]
    let perPage: Int = 100

    public var cacheKey: String? = "conversations"

    public var request: GetConversationsRequest {
        return GetConversationsRequest(include: include, perPage: perPage, scope: nil)
    }

    public var scope = Scope.all(orderBy: #keyPath(Conversation.lastMessageAt), ascending: false)

    public init() {}
}

public class GetConversation: APIUseCase {
    public typealias Model = Conversation
    public let id: String
    let include: [GetConversationRequest.Include]
    public var cacheKey: String? { "conversation-\(id)" }

    public var request: GetConversationRequest {
        return GetConversationRequest(id: id, include: include)
    }

    public var scope: Scope { Scope(predicate: NSPredicate(format: "%K == %@", "id", id), order: []) }

    public init(id: String, include: [GetConversationRequest.Include] = [.participant_avatars]) {
        self.id = id
        self.include = include
    }
}
