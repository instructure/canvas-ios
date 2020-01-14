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

public final class User: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var sortableName: String
    @NSManaged public var shortName: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var email: String?
    @NSManaged public var courseID: String?
    @NSManaged public var groupID: String?
    @NSManaged public var enrollments: Set<Enrollment>?
}

extension User: WriteableModel {
    @discardableResult
    public static func save(_ item: APIUser, in context: NSManagedObjectContext) -> User {
        let user: User = context.first(where: #keyPath(User.id), equals: item.id.value) ?? context.insert()
        user.id = item.id.value
        user.name = item.name
        user.shortName = item.short_name
        user.sortableName = item.sortable_name
        user.email = item.email
        user.avatarURL = item.avatar_url?.rawValue
        if let enrollments = item.enrollments {
            user.enrollments = Set(enrollments.map { item in
                let enrollment = context.insert() as Enrollment
                enrollment.update(fromApiModel: item, course: nil, in: context)
                return enrollment
            })
        }
        return user
    }
}

extension User {
    public func formattedRole(in context: Context) -> String? {
        enrollments?.first { $0.canvasContextID == context.canvasContextID }?.formattedRole
    }
}
