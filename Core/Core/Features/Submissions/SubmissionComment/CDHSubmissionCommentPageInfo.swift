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

import CoreData

final public class CDHSubmissionCommentPageInfo: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var startCursor: String?
    @NSManaged public var hasNextPage: Bool
    @NSManaged public var hasPreviousPage: Bool
    @NSManaged public var pageID: String?

    @discardableResult
    public static func save(
        _ apiEntity: GetHSubmissionCommentsResponse.PageInfo?,
        id: String,
        attempt: Int,
        pageID: String?,
        in context: NSManagedObjectContext
    ) -> CDHSubmissionCommentPageInfo {
        let dbEntity: CDHSubmissionCommentPageInfo = context.insert()
        dbEntity.id = id
        dbEntity.startCursor = apiEntity?.startCursor
        dbEntity.hasNextPage = apiEntity?.hasNextPage ?? false
        dbEntity.hasPreviousPage = apiEntity?.hasPreviousPage ?? false
        dbEntity.pageID = pageID ?? ""
        return dbEntity
    }
}
