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

public struct InboxMessageModel: Identifiable, Equatable {
    public let id: String
    public let avatar: Avatar
    public let participantName: String
    public let title: String
    public let message: String
    public let date: String
    public let isStarred: Bool
    public let isUnread: Bool

    public init(id: String,
                avatar: Avatar,
                participantName: String,
                title: String,
                message: String,
                date: String,
                isStarred: Bool,
                isUnread: Bool) {
        self.id = id
        self.avatar = avatar
        self.participantName = participantName
        self.title = title
        self.message = message
        self.date = date
        self.isStarred = isStarred
        self.isUnread = isUnread
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
        self.avatar = Avatar(participants: participants)
        self.participantName = participants.names
        self.title = conversation.subject ?? ""
        self.message = conversation.last_message ?? conversation.last_authored_message ?? ""
        self.date = (conversation.last_message_at ?? conversation.last_authored_message_at ?? Date()).relativeDateOnlyString
        self.isStarred = conversation.starred
        self.isUnread = conversation.workflow_state == .unread
    }

    public func makeCopy(isUnread: Bool) -> InboxMessageModel {
        InboxMessageModel(id: id,
                          avatar: avatar,
                          participantName: participantName,
                          title: title,
                          message: message,
                          date: date,
                          isStarred: isStarred,
                          isUnread: isUnread)
    }
}

#if DEBUG

public extension InboxMessageModel {
    static var mock: InboxMessageModel { mock() }
    static func mock(id: String = "0", participantName: String = "Bob, Alice") -> InboxMessageModel {
        InboxMessageModel(id: id,
                          avatar: .group,
                          participantName: participantName,
                          title: "Homework Feedback. Please read this as soon as possible as it's very important.",
                          message: "Did you check my homework? It would be very iportant to get some feedback before the end of the week.",
                          date: "22/10/13",
                          isStarred: true,
                          isUnread: true)
    }
}

public extension Array where Element == InboxMessageModel {

    static func mock(count: Int) -> [InboxMessageModel] {
        (0..<count).reduce(into: [], { partialResult, index in
            partialResult.append(.mock(id: "\(index)"))
        })
    }
}

#endif
