//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public final class ContextUser: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var sortableName: String
    @NSManaged public var shortName: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var email: String?
    @NSManaged public var pronouns: String?
    @NSManaged public var courseID: String?
    @NSManaged public var groupID: String?
    @NSManaged public var enrollments: Set<ContextEnrollment>

    private var scope: Scope {
        Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ContextEnrollment.userID), equals: id),
            NSPredicate(key: #keyPath(ContextEnrollment.course.id), equals: courseID),
        ]), order: [])
    }
}

extension ContextUser: WriteableModel {
    @discardableResult
    public static func save(_ item: APIUser, in context: NSManagedObjectContext) -> ContextUser {
        let predicates = [NSPredicate(key: #keyPath(User.id), equals: item.id.value),
                          NSPredicate(key: #keyPath(User.groupID), equals: item.group_id),
                          NSPredicate(key: #keyPath(User.courseID), equals: item.course_id), ]
        let userPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let scope = Scope(predicate: userPredicate, order: [])
        let user: ContextUser = context.first(scope: scope) ?? context.insert()
        user.id = item.id.value
        user.name = item.name
        user.shortName = item.short_name
        user.sortableName = item.sortable_name
        user.email = item.email
        user.avatarURL = item.avatar_url?.rawValue
        user.pronouns = item.pronouns
        user.courseID = item.course_id
        user.groupID = item.group_id
        if let enrollments = item.enrollments {
            for enrollment in enrollments {
                let userEnrollment = context.insert() as ContextEnrollment
                var course: Course?
                if let courseID = enrollment.course_id?.value {
                    course = context.first(where: #keyPath(Course.id), equals: courseID)
                }
                userEnrollment.update(fromApiModel: enrollment, course: course, in: context)
            }
        }
        return user
    }
}

extension ContextUser {
    public var displayName: String { ContextUser.displayName(name, pronouns: pronouns) }

    public static func displayName(_ name: String, pronouns: String?) -> String {
        if let pronouns = pronouns {
            let format = NSLocalizedString("User.displayName", bundle: .core, value: "%@ (%@)", comment: "Name and pronouns - John (He/Him)")
            return String.localizedStringWithFormat(format, name, pronouns)
        }
        return name
    }

    public func formattedRole(in context: Context) -> String? {
        enrollments.first { $0.canvasContextID == context.canvasContextID }?.formattedRole
    }
}
