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

public final class SearchRecipient: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var fullName: String
    @NSManaged public var roles: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var filter: String

    @discardableResult
    public static func save(_ item: APISearchRecipient, filter: String, in context: NSManagedObjectContext) -> SearchRecipient {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(SearchRecipient.id), item.id.value, #keyPath(SearchRecipient.filter), filter)
        let model: SearchRecipient = context.fetch(predicate).first ?? context.insert()

        model.id = item.id.value
        model.fullName = item.full_name
        model.avatarURL = item.avatar_url
        model.filter = filter

        var allRoles: Set<String> = Set()
        for (_, courseRoles) in item.common_courses {
            courseRoles.forEach { role in
                allRoles.insert(role.replacingOccurrences(of: "Enrollment", with: ""))
            }
        }
        var roles = Array(allRoles)
        roles.sort()
        model.roles = roles.joined(separator: ", ")

        return model
    }
}
