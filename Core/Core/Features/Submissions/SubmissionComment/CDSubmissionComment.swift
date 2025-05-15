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

final public class CDSubmissionComment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var attemptFromAPI: NSNumber?
    @NSManaged public var authorID: String?
    @NSManaged public var authorName: String?
    @NSManaged public var comment: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isRead: Bool

    public var attempt: Int? {
        if let attemptFromAPI {
            return Int(truncating: attemptFromAPI)
        } else {
            return nil
        }
    }

    @discardableResult
    public static func save(
        _ apiEntity: GetSubmissionCommentsResponse.Comment?,
        assignmentID: String,
        in context: NSManagedObjectContext
    ) -> CDSubmissionComment {

        let dbEntity: CDSubmissionComment = context.first(
            where: #keyPath(CDSubmissionComment.id),
            equals: apiEntity?.id
        ) ?? context.insert()

        dbEntity.id = apiEntity?.id ?? ""
        dbEntity.attemptFromAPI = if let attempt = apiEntity?.attempt { NSNumber(value: attempt) } else { nil }
        dbEntity.authorID = apiEntity?.author?.id
        dbEntity.authorName = apiEntity?.author?.shortName
        dbEntity.comment = apiEntity?.comment
        dbEntity.createdAt = apiEntity?.createdAt
        dbEntity.isRead = apiEntity?.read ?? true

        return dbEntity
    }
}
