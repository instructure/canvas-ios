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

class UpdateAssignment: APIUseCase {
    typealias Model = Assignment

    let request: PutAssignmentRequest

    init(
        courseID: String,
        assignmentID: String,
        description: String? = nil,
        dueAt: Date?,
        gradingType: GradingType?,
        lockAt: Date?,
        name: String? = nil,
        onlyVisibleToOverrides: Bool? = false,
        overrides: [APIAssignmentOverride]?,
        pointsPossible: Double?,
        published: Bool? = nil,
        unlockAt: Date?
    ) {
        request = PutAssignmentRequest(
            courseID: courseID,
            assignmentID: assignmentID,
            body: .init(assignment: .init(
                assignment_overrides: overrides,
                description: description,
                due_at: dueAt,
                grading_type: gradingType,
                lock_at: lockAt,
                name: name,
                only_visible_to_overrides: onlyVisibleToOverrides,
                points_possible: pointsPossible,
                published: published,
                unlock_at: unlockAt
            ))
        )
    }

    var cacheKey: String? { nil }

    func write(response: APIAssignment?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        Assignment.save(item, in: client, updateSubmission: false, updateScoreStatistics: false)
    }
}
