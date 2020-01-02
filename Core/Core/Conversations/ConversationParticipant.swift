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

public final class ConversationParticipant: NSManagedObject, WriteableModel {
    @NSManaged public var avatarURL: URL?
    @NSManaged public var id: String
    @NSManaged public var name: String

    public static func save(_ item: APIConversationParticipant, in context: NSManagedObjectContext) -> ConversationParticipant {
        let model: ConversationParticipant = context.first(where: #keyPath(ConversationParticipant.id), equals: item.id.value) ?? context.insert()
        model.avatarURL = item.avatar_url?.rawValue
        model.id = item.id.value
        model.name = item.name
        return model
    }
}
