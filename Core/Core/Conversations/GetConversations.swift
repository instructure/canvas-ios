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
import CoreData

public class GetConversations: CollectionUseCase {
    public typealias Model = Conversation
    public typealias Response = Request.Response

    let include: [GetConversationsRequest.Include] = [.participant_avatars]
    let perPage: Int = 100
    let requestScope: GetConversationsRequest.Scope?
    public var cacheKey: String? {
        let scope = requestScope?.rawValue ?? "all"
        return "conversations-\(scope)-\(filter ?? "")"
    }
    let filter: String?

    public var request: GetConversationsRequest {
        return GetConversationsRequest(include: include, perPage: perPage, scope: requestScope, filter: filter)
    }

    public var scope: Scope {
        if let filter = filter {
            return Scope(
                predicate: NSPredicate(format: "%K == %@", #keyPath(Conversation.contextCode), filter),
                order: [NSSortDescriptor(key: #keyPath(Conversation.lastMessageAt), ascending: false) ]
            )
        } else {
            return Scope.all(orderBy: #keyPath(Conversation.lastMessageAt), ascending: false)
        }
    }

    public init(scope: GetConversationsRequest.Scope? = nil, filter: String? = nil) {
        self.requestScope = scope
        self.filter = filter
    }
}

public class GetConversationsWithSent: APIUseCase {
    public typealias Model = Conversation
    let include: [GetConversationsRequest.Include] = [.participant_avatars]
    let perPage: Int = 100

    public var cacheKey: String? = "conversations"

    public var request: GetConversationsRequest {
        return GetConversationsRequest(include: include, perPage: perPage, scope: nil, filter: nil)
    }

    public var scope = Scope.all(orderBy: #keyPath(Conversation.lastMessageAt), ascending: false)

    public init() {}

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APIConversation]?, URLResponse?, Error?) -> Void) {
        environment.api.exhaust(request) { [weak self] (conversations, response, error) in
            guard let self = self, error == nil else {
                completionHandler(nil, response, error)
                return
            }

            let sentRequest = GetConversationsRequest(include: self.include, perPage: self.perPage, scope: .sent, filter: nil)
            environment.api.exhaust(sentRequest) { (sentConversations, sentResponse, sentError) in
                if let error = sentError {
                    completionHandler(nil, sentResponse, error)
                    return
                }
                completionHandler((conversations ?? []) + (sentConversations ?? []), response, nil)
            }
        }
    }
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

public class UpdateConversation: APIUseCase {
    public var cacheKey: String?
    public typealias Model = Conversation
    public let id: String
    public let state: ConversationWorkflowState

    public var request: PutConversationRequest {
        return PutConversationRequest(id: id, workflowState: state)
    }

    public var scope: Scope { Scope(predicate: NSPredicate(format: "%K == %@", "id", id), order: []) }

    public init(id: String, state: ConversationWorkflowState) {
        self.id = id
        self.state = state
    }

    public func write(response: APIConversation?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        // currently `UpdateConversations` is used to mark a discussion as unread. The response does not
        //  include `context_name` field, so it makes cells jump, so not updating the whole object.
        let conversation: Conversation? = client.first(where: #keyPath(Conversation.id), equals: response?.id.value ?? "")
        if let workflowState = response?.workflow_state { conversation?.workflowState = workflowState }
        try? client.save()
    }
}
