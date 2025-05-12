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

final public class CDAssignmentSubmissionComment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var assignmentID: String
    @NSManaged public var hasUnreadComment: Bool
    @NSManaged public var comments: Set<CDAssignmentComment>

    @discardableResult
    public static func save(
        _ apiEntity: GetSubmissionCommentsResponse,
        assignmentID: String,
        in context: NSManagedObjectContext
    ) -> CDAssignmentSubmissionComment {

        let dbEntity: CDAssignmentSubmissionComment = context.first(
            where: #keyPath(CDAssignmentSubmissionComment.id),
            equals: apiEntity.data?.submission?.id
        ) ?? context.insert()

        let submission = apiEntity.data?.submission

        dbEntity.id = submission?.id ?? ""
        dbEntity.assignmentID = assignmentID
        dbEntity.hasUnreadComment = (submission?.unreadCommentCount ?? 0) > 0

        if let commentsConnection = submission?.commentsConnection?.edges {
            let commentEntities: [CDAssignmentComment] = commentsConnection.map { apiItem in
                return CDAssignmentComment.save(apiItem.node, assignmentID: assignmentID, in: context)
            }
            dbEntity.comments = Set(commentEntities)
        } else {
            dbEntity.comments = []
        }

        return dbEntity
    }

}
