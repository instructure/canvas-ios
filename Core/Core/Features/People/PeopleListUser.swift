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

public final class PeopleListUser: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var sortableName: String
    @NSManaged public var shortName: String
    @NSManaged public var avatarURL: URL?
    @NSManaged public var email: String?
    @NSManaged public var pronouns: String?
    @NSManaged public var courseID: String?
    @NSManaged public var groupID: String?
    @NSManaged public var enrollments: Set<PeopleListEnrollment>

    private var scope: Scope {
        Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(PeopleListEnrollment.enrolledUser.id), equals: id),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(PeopleListEnrollment.canvasContextID), equals: "course_\(courseID ?? "")"),
                NSPredicate(key: #keyPath(PeopleListEnrollment.canvasContextID), equals: "group_\(groupID ?? "")")
            ])
        ]), order: [])
    }
}

extension PeopleListUser {
    @discardableResult
    public static func save(_ item: APIUser, courseId: String? = nil, groupId: String? = nil, in context: NSManagedObjectContext) -> PeopleListUser {
        let predicates = [NSPredicate(key: #keyPath(PeopleListUser.id), equals: item.id.value),
                          NSPredicate(key: #keyPath(PeopleListUser.groupID), equals: groupId),
                          NSPredicate(key: #keyPath(PeopleListUser.courseID), equals: courseId) ]
        let userPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let scope = Scope(predicate: userPredicate, order: [])
        let user: PeopleListUser = context.first(scope: scope) ?? context.insert()
        user.id = item.id.value
        user.name = item.name
        user.shortName = item.short_name
        user.sortableName = item.sortable_name
        user.email = item.email
        user.avatarURL = item.avatar_url?.rawValue
        user.pronouns = item.pronouns
        user.courseID = courseId
        user.groupID = groupId
        if let apiEnrollments = item.enrollments {
            for enrollment in apiEnrollments {
                let userEnrollment: PeopleListEnrollment = context.first(where: #keyPath(PeopleListEnrollment.id), equals: enrollment.id?.value) ?? context.insert()
                userEnrollment.update(fromApiModel: enrollment, user: user, in: context)
                user.enrollments.insert(userEnrollment)
            }
        }
        return user
    }
}

extension PeopleListUser {
    public var displayName: String { User.displayName(name, pronouns: pronouns) }
}
