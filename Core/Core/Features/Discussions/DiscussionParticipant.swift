//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public final class DiscussionParticipant: NSManagedObject, WriteableModel {
    @NSManaged public var avatarURL: URL?
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var pronouns: String?

    public var displayName: String {
        User.displayName(name, pronouns: pronouns)
    }

    @discardableResult
    public static func save(_ item: APIDiscussionParticipant, in context: NSManagedObjectContext) -> DiscussionParticipant {
        let id = item.id?.value ?? ""
        let model: DiscussionParticipant = context.first(where: #keyPath(DiscussionParticipant.id), equals: id) ?? context.insert()
        model.avatarURL = item.avatar_image_url?.rawValue
        model.id = id
        model.name = item.display_name ?? ""
        model.pronouns = item.pronouns
        return model
    }
}
