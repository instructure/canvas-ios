//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

final public class CDInboxEnrollment: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var userId: String
    @NSManaged public var canvasContextID: String?
    @NSManaged public var observedUserId: String?
    @NSManaged public var observedUserDisplayName: String?

    @discardableResult
    public static func save(_ item: APIEnrollment, in context: NSManagedObjectContext) -> CDInboxEnrollment? {
        guard let id = item.id?.value, let courseId = item.course_id?.value else { return nil }
        let dbEntity: CDInboxEnrollment = context.first(where: #keyPath(CDInboxEnrollment.id), equals: item.id?.value) ?? context.insert()
        dbEntity.userId = item.user_id.value
        dbEntity.id = id

        dbEntity.canvasContextID = "course_\(courseId)"

        if let apiUser = item.observed_user {
            let observedUserModel: User = User.save(apiUser, in: context)
            dbEntity.observedUserId = observedUserModel.id
            dbEntity.observedUserDisplayName = observedUserModel.name
        }
        return dbEntity
    }
}
