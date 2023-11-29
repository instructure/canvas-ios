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
    @NSManaged public var name: String
    @NSManaged public var fullName: String
    @NSManaged public var pronouns: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var filter: String
    @NSManaged public var commonCourses: Set<CommonCourse>

    public var displayName: String? {
        User.displayName(name, pronouns: pronouns)
    }

    @discardableResult
    public static func save(_ item: APISearchRecipient, filter: String, in context: NSManagedObjectContext) -> SearchRecipient {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(SearchRecipient.id), item.id.value, #keyPath(SearchRecipient.filter), filter)
        let model: SearchRecipient = context.fetch(predicate).first ?? context.insert()

        model.id = item.id.value
        model.name = item.name
        model.fullName = item.full_name ?? item.name
        model.pronouns = item.pronouns
        model.avatarURL = item.avatar_url?.rawValue
        model.filter = filter
        model.commonCourses = []

        if let common_courses = item.common_courses {
            for (courseID, roles) in common_courses {
                for role in roles {
                    let commonCourse: CommonCourse = context.insert()
                    commonCourse.courseID = courseID
                    commonCourse.role = role
                    model.commonCourses.insert(commonCourse)
                }
            }
        }
        return model
    }

    public func hasRole(_ role: Role, in context: Context) -> Bool {
        guard context.contextType == .course else { return false }
        return commonCourses.contains { $0.courseID == context.id && Role(rawValue: $0.role) == role }
    }
}

#if DEBUG

public extension SearchRecipient {
    static func make(id: String = "0",
                     name: String = "Bob, Alice",
                     in context: NSManagedObjectContext)
    -> SearchRecipient {
        let mockObject: SearchRecipient = context.insert()
        mockObject.id = id
        mockObject.name = name
        mockObject.fullName = name
        mockObject.filter = ""
        mockObject.commonCourses = []
        return mockObject
    }
}

#endif
