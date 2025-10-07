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

final public class CDHCommentAttachment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var url: String?
    @NSManaged public var displayName: String?

    @discardableResult
    public static func save(
        _ apiEntity: GetHSubmissionCommentsResponse.Attachment,
        in context: NSManagedObjectContext
    ) -> CDHCommentAttachment {

        let dbEntity: CDHCommentAttachment = context.first(
            where: #keyPath(CDHCommentAttachment.id),
            equals: apiEntity.id
        ) ?? context.insert()
        dbEntity.id = apiEntity.id
        dbEntity.url = apiEntity.url
        dbEntity.displayName = apiEntity.displayName
        return dbEntity
    }
}
