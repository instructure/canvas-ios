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

final public class CDScoresAssignment: NSManagedObject {
    // MARK: - Propertites

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var commentsCount: NSNumber?
    @NSManaged public var dueAt: Date?
    @NSManaged public var htmlUrl: URL?
    @NSManaged public var pointsPossible: Double
    @NSManaged public var score: NSNumber?
    @NSManaged public var state: String?
    @NSManaged public var isRead: Bool
    @NSManaged public var isExcused: Bool
    @NSManaged public var isLate: Bool
    @NSManaged public var isMissing: Bool
    @NSManaged public var submittedAt: Date?

    @discardableResult
    public static func save(
        _ apiEntity: GetSubmissionScoresResponse.Assignment,
        in context: NSManagedObjectContext
    ) -> CDScoresAssignment {

        let dbEntity: CDScoresAssignment = context.first(
            where: #keyPath(CDScoresAssignment.id),
            equals: apiEntity.id
        ) ?? context.insert()

        let submission = apiEntity.submissionsConnection?.nodes?.first

        dbEntity.id = apiEntity.id ?? ""
        dbEntity.name = apiEntity.name
        dbEntity.dueAt = apiEntity.dueAt
        dbEntity.htmlUrl = apiEntity.htmlUrl
        dbEntity.score = if let score = submission?.score {
            NSNumber(value: score)
        } else {
            nil
        }
        dbEntity.state = submission?.state
        dbEntity.isLate = submission?.late ?? false
        dbEntity.isExcused = submission?.excused ?? false
        dbEntity.isMissing = submission?.missing ?? false
        dbEntity.submittedAt = submission?.submittedAt

        dbEntity.commentsCount = NSNumber(value: submission?.commentsConnection?.nodes?.count ?? 0)
        dbEntity.pointsPossible = apiEntity.pointsPossible ?? 0
        dbEntity.isRead = (submission?.unreadCommentCount ?? 0) == 0

        return dbEntity
    }
}
