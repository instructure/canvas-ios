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

final public class CDSubmissionScores: NSManagedObject {
    @NSManaged public var enrollmentID: String
    @NSManaged public var assignmentGroups: Set<CDHScoresAssignmentGroup>

    @discardableResult
    public static func save(
        _ apiEntity: GetSubmissionScoresResponse,
        enrollmentId: String,
        in context: NSManagedObjectContext
    ) -> CDSubmissionScores {
        let dbEntity: CDSubmissionScores = context.first(where: #keyPath(CDSubmissionScores.enrollmentID), equals: enrollmentId) ?? context.insert()

        dbEntity.enrollmentID = enrollmentId
        if let apiAssignmentGroups = apiEntity.data?.legacyNode?.course?.assignmentGroups {
            let assignmentsEntities: [CDHScoresAssignmentGroup] = apiAssignmentGroups.map { apiItem in
                return CDHScoresAssignmentGroup.save(apiItem, enrollmentId: enrollmentId, in: context)
            }
            dbEntity.assignmentGroups = Set(assignmentsEntities)
        } else {
            dbEntity.assignmentGroups = []
        }
        return dbEntity
    }
}
