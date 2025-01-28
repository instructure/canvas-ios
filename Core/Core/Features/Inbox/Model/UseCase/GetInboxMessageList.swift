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

import CoreData

public class GetInboxMessageList: CollectionUseCase {
    public typealias Model = InboxMessageListItem

    public var cacheKey: String? { "inbox/\(messageScope.rawValue)?contextCode=\(context?.canvasContextID ?? "all")" }
    public var request: GetConversationsRequest {
        GetConversationsRequest(include: [.participant_avatars],
                                perPage: 20,
                                scope: messageScope.apiScope,
                                filter: context?.canvasContextID)
    }
    public var scope: Scope {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            messageScope.messageFilter,
            context.inboxMessageFilter
        ])
        let order = [
            NSSortDescriptor(key: #keyPath(InboxMessageListItem.dateRaw), ascending: false)
        ]
        return Scope(predicate: predicate, order: order)
    }

    public var messageScope: InboxMessageScope = .inbox
    public var context: Context?
    private let currentUserId: String

    public init(currentUserId: String) {
        self.currentUserId = currentUserId
    }

    public func write(response: [APIConversation]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }

        for apiEntity in response {
            InboxMessageListItem.save(apiEntity,
                                      currentUserID: currentUserId,
                                      isSent: messageScope == .sent,
                                      contextFilter: context,
                                      scopeFilter: messageScope,
                                      in: client)
        }
    }

    public func invalidateCaches(in context: NSManagedObjectContext) {
        let predicate = NSPredicate(format: "%K BEGINSWITH 'inbox/'", #keyPath(TTL.key))
        let cacheEntries: [TTL] = context.fetch(predicate)
        context.delete(cacheEntries)
        try? context.save()
    }
}
