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

public final class InboxMessageListItem2: NSManagedObject {
    public typealias JSON = APIConversation

    @NSManaged public var id: String
    @NSManaged public var contextCode: String?
    @NSManaged public var participantName: String
    @NSManaged public var title: String
    @NSManaged public var message: String
    @NSManaged public var isStarred: Bool
    /** Local helper, not present on the API. */
    @NSManaged public var isSent: Bool

    // MARK: Convertible Raw Properties

    @NSManaged public var dateRaw: Date
    /** String value of `ConversationWorkflowState` cases. */
    @NSManaged public var stateRaw: String
    @NSManaged public var avatarNameRaw: String?
    @NSManaged public var avatarURLRaw: URL?

    // MARK: - Helper Properties

    public var state: ConversationWorkflowState {
        get {
            ConversationWorkflowState(rawValue: stateRaw) ?? .unread
        }
        set {
            stateRaw = newValue.rawValue
        }
    }
    public var isMarkAsReadActionAvailable: Bool {
        state == .unread || state == .archived
    }
    public var isArchiveActionAvailable: Bool {
        state != .archived
    }
    public var date: String {
        dateRaw.relativeDateOnlyString
    }
    public var avatar: InboxMessageAvatar {
        if let name = avatarNameRaw {
            return .individual(name: name, profileImageURL: avatarURLRaw)
        } else {
            return .group
        }
    }

    // MARK: - CoreData Save

    @discardableResult
    public static func save(_ apiEntity: APIConversation,
                            currentUserID: String,
                            isSent: Bool,
                            in context: NSManagedObjectContext)
    -> InboxMessageListItem2 {
        let participants: [APIConversationParticipant] = {
            if apiEntity.participants.count > 1 {
                return apiEntity.participants.filter { $0.id.value != currentUserID }
            } else {
                return Array(apiEntity.participants)
            }
        }()
        let avatar = InboxMessageAvatar(participants: participants)

        let dbEntity: InboxMessageListItem2 = context.first(where: #keyPath(InboxMessageListItem2.id),
                                                            equals: apiEntity.id.value) ?? context.insert()
        dbEntity.id = apiEntity.id.rawValue
        dbEntity.contextCode = apiEntity.context_code
        dbEntity.participantName = participants.names
        dbEntity.title = apiEntity.subject ?? ""
        dbEntity.message = apiEntity.last_message ?? apiEntity.last_authored_message ?? ""
        dbEntity.isStarred = apiEntity.starred
        dbEntity.dateRaw = (apiEntity.last_message_at ?? apiEntity.last_authored_message_at ?? Date())
        dbEntity.stateRaw = apiEntity.workflow_state.rawValue
        dbEntity.isSent = isSent

        if case .individual(let name, let profileImageURL) = avatar {
            dbEntity.avatarNameRaw = name
            dbEntity.avatarURLRaw = profileImageURL
        }

        return dbEntity
    }
}

public struct InboxMessageListItem: Identifiable, Equatable {
    public let id: String
    public let avatar: InboxMessageAvatar
    public let participantName: String
    public let title: String
    public let message: String
    public let date: String
    public let isStarred: Bool
    public let state: ConversationWorkflowState

    public var isMarkAsReadActionAvailable: Bool {
        state == .unread || state == .archived
    }
    public var isArchiveActionAvailable: Bool {
        state != .archived
    }

    public init(id: String,
                avatar: InboxMessageAvatar,
                participantName: String,
                title: String,
                message: String,
                date: String,
                isStarred: Bool,
                state: ConversationWorkflowState) {
        self.id = id
        self.avatar = avatar
        self.participantName = participantName
        self.title = title
        self.message = message
        self.date = date
        self.isStarred = isStarred
        self.state = state
    }

    public init(conversation: APIConversation, currentUserID: String) {
        let participants: [APIConversationParticipant] = {
            if conversation.participants.count > 1 {
                return conversation.participants.filter { $0.id.value != currentUserID }
            } else {
                return Array(conversation.participants)
            }
        }()
        self.id = conversation.id.value
        self.avatar = InboxMessageAvatar(participants: participants)
        self.participantName = participants.names
        self.title = conversation.subject ?? ""
        self.message = conversation.last_message ?? conversation.last_authored_message ?? ""
        self.date = (conversation.last_message_at ?? conversation.last_authored_message_at ?? Date()).relativeDateOnlyString
        self.isStarred = conversation.starred
        self.state = conversation.workflow_state
    }

    public func makeCopy(withState: ConversationWorkflowState) -> InboxMessageListItem {
        InboxMessageListItem(id: id,
                          avatar: avatar,
                          participantName: participantName,
                          title: title,
                          message: message,
                          date: date,
                          isStarred: isStarred,
                          state: withState)
    }
}

#if DEBUG

public extension InboxMessageListItem {
    static var mock: InboxMessageListItem { mock() }
    static func mock(id: String = "0", participantName: String = "Bob, Alice") -> InboxMessageListItem {
        InboxMessageListItem(id: id,
                          avatar: .group,
                          participantName: participantName,
                          title: "Homework Feedback. Please read this as soon as possible as it's very important.",
                          message: "Did you check my homework? It would be very iportant to get some feedback before the end of the week.",
                          date: "22/10/13",
                          isStarred: true,
                          state: .unread)
    }
}

public extension Array where Element == InboxMessageListItem {

    static func mock(count: Int) -> [InboxMessageListItem] {
        (0..<count).reduce(into: [], { partialResult, index in
            partialResult.append(.mock(id: "\(index)"))
        })
    }
}

#endif
