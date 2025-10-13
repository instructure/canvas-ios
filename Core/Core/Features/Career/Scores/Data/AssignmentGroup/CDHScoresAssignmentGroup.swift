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

final public class CDHScoresAssignmentGroup: NSManagedObject {
    // MARK: - Propertites

    @NSManaged public var enrollmentID: String
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var groupWeight: NSNumber?
    @NSManaged public var assignments: Set<CDHScoresAssignment>

    @discardableResult
    public static func save(
        _ apiEntity: GetHSubmissionScoresResponse.AssignmentGroup,
        enrollmentId: String,
        in context: NSManagedObjectContext
    ) -> CDHScoresAssignmentGroup {
        let dbEntity: CDHScoresAssignmentGroup = context.first(where: #keyPath(CDHScoresAssignmentGroup.id), equals: apiEntity.id) ?? context.insert()

        dbEntity.enrollmentID = enrollmentId
        dbEntity.id = apiEntity.id ?? ""
        dbEntity.name = apiEntity.name
        dbEntity.groupWeight = if let groupWeight = apiEntity.groupWeight { NSNumber(value: groupWeight) } else { nil }
        if let apiAssignments = apiEntity.assignmentsConnection?.nodes {
            let assignmentsEntities: [CDHScoresAssignment] = apiAssignments.map { apiItem in
                return CDHScoresAssignment.save(apiItem, in: context)
            }
            dbEntity.assignments = Set(assignmentsEntities)
        } else {
            dbEntity.assignments = []
        }
        return dbEntity
    }
}
