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

public struct InboxMessageModel: Identifiable {
    public enum ParticipantAvatar {
        case individual(name: String, profileImageURL: URL?)
        case group
    }

    public let id: String
    public let avatar: ParticipantAvatar
    public let participantName: String
    public let title: String
    public let message: String
    public let date: String
    public let isStarred: Bool
    public let isUnread: Bool

    public init(id: String,
                avatar: ParticipantAvatar,
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

    public init(conversation: Conversation) {
        self.id = conversation.id
        self.avatar = .group
        self.participantName = "test name"
        self.title = conversation.subject
        self.message = conversation.lastMessage
        self.date = conversation.lastMessageAt?.dateTimeString ?? ""
        self.isStarred = conversation.starred
        self.isUnread = conversation.workflowState == .unread
    }
}

extension InboxMessageModel: Equatable {
    public static func == (lhs: InboxMessageModel, rhs: InboxMessageModel) -> Bool {
        lhs.id == rhs.id
    }
}

#if DEBUG

public extension InboxMessageModel {
    static var mock: InboxMessageModel { mock() }
    static func mock(id: String = "0") -> InboxMessageModel {
        InboxMessageModel(id: id,
                          avatar: .group,
                          participantName: "Bob, Alice",
                          title: "Homework Feedback. Please read this as soon as possible as it's very important.",
                          message: "Did you check my homework? It would be very iportant to get some feedback before the end of the week.",
                          date: "2022/10/13",
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
