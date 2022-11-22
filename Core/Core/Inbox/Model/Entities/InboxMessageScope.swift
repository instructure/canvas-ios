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

import Foundation

public enum InboxMessageScope: String, CaseIterable, Hashable {
    case all, unread, starred, sent, archived

    public var localizedName: String {
        switch self {
        case .all: return NSLocalizedString("All", comment: "")
        case .unread: return NSLocalizedString("Unread", comment: "")
        case .starred: return NSLocalizedString("Starred", comment: "")
        case .sent: return NSLocalizedString("Sent", comment: "")
        case .archived: return NSLocalizedString("Archived", comment: "")
        }
    }

    public var apiScope: GetConversationsRequest.Scope? {
        switch self {
        case .all: return nil
        case .unread: return .unread
        case .starred: return .starred
        case .sent: return .sent
        case .archived: return .archived
        }
    }

    public var messageFilter: NSPredicate {
        switch self {
        case .all:
            let readAndUnread = NSPredicate(format: "%K IN %@",
                                            #keyPath(InboxMessageListItem2.stateRaw),
                                            [
                                                ConversationWorkflowState.read.rawValue,
                                                ConversationWorkflowState.unread.rawValue,
                                            ])
            let notSent = NSPredicate(format: "%K == false", #keyPath(InboxMessageListItem2.isSent))
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                readAndUnread,
                notSent,
            ])
        case .unread:
            return NSPredicate(format: "%K == %@",
                               #keyPath(InboxMessageListItem2.stateRaw),
                               ConversationWorkflowState.unread.rawValue)
        case .starred:
            return NSPredicate(key: #keyPath(InboxMessageListItem2.isStarred),
                               equals: true)
        case .sent:
            return NSPredicate(key: #keyPath(InboxMessageListItem2.isSent),
                               equals: true)
        case .archived:
            return NSPredicate(format: "%K == %@",
                               #keyPath(InboxMessageListItem2.stateRaw),
                               ConversationWorkflowState.archived.rawValue)
        }
    }
}
