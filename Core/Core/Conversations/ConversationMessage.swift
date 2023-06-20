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

public final class ConversationMessage: NSManagedObject, WriteableModel {
    @NSManaged var attachmentsRaw: NSOrderedSet?
    @NSManaged public var authorID: String
    @NSManaged public var body: String
    @NSManaged public var createdAt: Date?
    @NSManaged var forwardedRaw: NSOrderedSet?
    @NSManaged public var generated: Bool
    @NSManaged public var id: String
    @NSManaged public var mediaComment: MediaComment?
    @NSManaged public var participantIDsRaw: String?

    public var participantIDs: [String] {
        get { participantIDsRaw?.components(separatedBy: ",") ?? [] }
        set { participantIDsRaw = newValue.joined(separator: ",") }
    }

    public var attachments: [File] {
        get { attachmentsRaw?.array as? [File] ?? [] }
        set { attachmentsRaw = NSOrderedSet(array: newValue) }
    }

    public var forwarded: [ConversationMessage] {
        get { forwardedRaw?.array as? [ConversationMessage] ?? [] }
        set { forwardedRaw = NSOrderedSet(array: newValue) }
    }

    public static func save(_ item: APIConversationMessage, in context: NSManagedObjectContext) -> ConversationMessage {
        let model: ConversationMessage = context.first(where: #keyPath(ConversationMessage.id), equals: item.id.value) ?? context.insert()
        model.attachments = item.attachments?.map {
            File.save($0, in: context)
        } ?? []
        model.authorID = item.author_id.value
        model.body = item.body
        model.createdAt = item.created_at
        model.forwarded = item.forwarded_messages?.map {
            ConversationMessage.save($0, in: context)
        } ?? []
        model.generated = item.generated
        model.id = item.id.value
        model.mediaComment = item.media_comment.flatMap {
            MediaComment.save($0, in: context)
        }

        model.participantIDs = item.participating_user_ids?.map { $0.value } ?? []

        return model
    }
}

extension ConversationMessage {
    public func localizedAudience( myID: String, userMap: [String: ConversationParticipant] ) -> String {
        var user: String? = ""
        let audience = participantIDs.filter { $0 != authorID }
        let containsMe = audience.contains(myID)

        if audience.count == 1 {
            user =  containsMe ? NSLocalizedString("me", bundle: .core, comment: "") : userMap[ audience[0] ]?.displayName
        } else if audience.count > 1 {
            let cnt = containsMe ? audience.count - 1 : audience.count
            let pluralFormat = NSLocalizedString("conversation_recipients_to", bundle: .core, comment: "")
            let othersText = String.localizedStringWithFormat(pluralFormat, cnt)
            user = containsMe ? String.localizedStringWithFormat( NSLocalizedString("me & %@", bundle: .core, comment: ""), othersText) : othersText
        }

        let template = NSLocalizedString("to %@", bundle: .core, comment: "")
        return String.localizedStringWithFormat(template, user ?? "")
    }
}

#if DEBUG

public extension ConversationMessage {
    static func make(id: String = "0",
                     authorID: String = "0",
                     body: String = "",
                     in context: NSManagedObjectContext)
    -> ConversationMessage {
        let mockObject: ConversationMessage = context.insert()
        mockObject.id = id
        mockObject.authorID = authorID
        mockObject.body = body
        return mockObject
    }
}

public extension Array where Element == ConversationMessage {

    static func make(count: Int,
                     body: String = "",
                     in context: NSManagedObjectContext)
    -> [ConversationMessage] {
        (0..<count).reduce(into: [], { partialResult, index in
            partialResult.append(.make(id: "\(index)", body: body, in: context))
        })
    }
}

#endif
