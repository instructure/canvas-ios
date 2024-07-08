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

public final class InboxMessageListItem: NSManagedObject {
    @NSManaged public var messageId: String
    @NSManaged public var participantName: String
    @NSManaged public var title: String
    @NSManaged public var message: String
    @NSManaged public var isStarred: Bool

    // MARK: Convertible Raw Properties

    @NSManaged public var dateRaw: Date
    /** String value of `ConversationWorkflowState` cases. */
    @NSManaged public var stateRaw: String
    @NSManaged public var avatarNameRaw: String?
    @NSManaged public var avatarURLRaw: URL?

    // MARK: Local Helper Properties

    @NSManaged public var hasAttachment: Bool
    @NSManaged public var isSent: Bool
    /** The context (course) filter that was used to download the message from API. */
    @NSManaged public var contextFilter: String?
    /** The scope (all, unread, starred...) filter that was used to download the message from API. */
    @NSManaged public var scopeFilter: String

    // MARK: - Helper Properties

    public var state: ConversationWorkflowState {
        get {
            ConversationWorkflowState(rawValue: stateRaw) ?? .unread
        }
        set {
            stateRaw = newValue.rawValue
        }
    }
    public var isMarkAsReadActionAvailable: Bool { state == .unread || state == .archived }
    public var isArchiveActionAvailable: Bool { state != .archived }
    public var date: String { dateRaw.relativeDateOnlyString }
    public var avatar: InboxMessageAvatar {
        if let name = avatarNameRaw {
            return .individual(name: name, profileImageURL: avatarURLRaw)
        } else {
            return .group
        }
    }
    public var isUnread: Bool { state == .unread }

    // MARK: - CoreData Save

    @discardableResult
    public static func save(_ apiEntity: APIConversation,
                            currentUserID: String,
                            isSent: Bool,
                            contextFilter: Context?,
                            scopeFilter: InboxMessageScope,
                            in context: NSManagedObjectContext)
    -> InboxMessageListItem {
        let participants: [APIConversationParticipant] = {
            if apiEntity.participants.count > 1 {
                return apiEntity.participants.filter { $0.id.value != currentUserID }
            } else {
                return Array(apiEntity.participants)
            }
        }()
        let avatar = InboxMessageAvatar(participants: participants)

        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(InboxMessageListItem.messageId), apiEntity.id.value)
        let contextPredicate = contextFilter.inboxMessageFilter
        let scopePredicate = scopeFilter.messageFilter
        let uniqueObjectPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            idPredicate,
            contextPredicate,
            scopePredicate
        ])
        let scope = Scope(predicate: uniqueObjectPredicate, order: [])

        let dbEntity: InboxMessageListItem = context.first(scope: scope) ?? context.insert()
        dbEntity.messageId = apiEntity.id.rawValue
        dbEntity.participantName = participants.names
        dbEntity.title = apiEntity.subject ?? ""
        dbEntity.message = apiEntity.last_authored_message ?? apiEntity.last_message ?? ""
        dbEntity.isStarred = apiEntity.starred
        dbEntity.dateRaw = (apiEntity.last_authored_message_at ?? apiEntity.last_message_at ?? Date())
        dbEntity.stateRaw = apiEntity.workflow_state.rawValue
        dbEntity.isSent = isSent
        dbEntity.contextFilter = contextFilter?.canvasContextID
        dbEntity.scopeFilter = scopeFilter.rawValue
        dbEntity.hasAttachment = apiEntity.properties?.contains(.attachments) ?? false

        if case .individual(let name, let profileImageURL) = avatar {
            dbEntity.avatarNameRaw = name
            dbEntity.avatarURLRaw = profileImageURL
        }

        return dbEntity
    }
}

extension InboxMessageListItem: Identifiable {
    public var id: String { messageId }
}

#if DEBUG

public extension InboxMessageListItem {
    static func make(id: String = "0",
                     participantName: String = "Bob, Alice",
                     in context: NSManagedObjectContext)
    -> InboxMessageListItem {
        let mockObject: InboxMessageListItem = context.insert()
        mockObject.messageId = id
        mockObject.participantName = participantName
        mockObject.title = "Homework Feedback. Please read this as soon as possible as it's very important."
        mockObject.message = "Did you check my homework? It would be very iportant to get some feedback before the end of the week."
        mockObject.dateRaw = Date()
        mockObject.isStarred = true
        mockObject.stateRaw = ConversationWorkflowState.unread.rawValue
        mockObject.hasAttachment = true
        return mockObject
    }
}

public extension Array where Element == InboxMessageListItem {

    static func make(count: Int,
                     in context: NSManagedObjectContext)
    -> [InboxMessageListItem] {
        (0..<count).reduce(into: [], { partialResult, index in
            partialResult.append(.make(id: "\(index)", in: context))
        })
    }
}

#endif
