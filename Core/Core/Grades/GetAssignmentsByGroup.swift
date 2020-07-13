//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
import Foundation

public class GetAssignmentsByGroup: APIUseCase {
    public typealias Model = Assignment

    let courseID: String
    let gradingPeriodID: String?
    
    private let include: [GetAssignmentGroupsRequest.Include] = [ .assignments, .observed_users, .submission, .score_statistics ]

    public init(courseID: String, gradingPeriodID: String? = nil) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
    }

    public var cacheKey: String? {
        "courses/\(courseID)/assignment_groups?grading_period_id=\(gradingPeriodID ?? "")"
    }

    public var request: GetAssignmentGroupsRequest { GetAssignmentGroupsRequest(
        courseID: courseID,
        gradingPeriodID: gradingPeriodID,
        include: include,
        perPage: 100
    ) }

    public var scope: Scope { Scope(
        predicate: NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: courseID),
        order: [
            NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.position), ascending: true),
            NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Assignment.position), ascending: true),
            NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, naturally: true),
        ],
        sectionNameKeyPath: #keyPath(Assignment.assignmentGroup.name)
    ) }

    public func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(NSPredicate(key: #keyPath(AssignmentGroup.courseID), equals: courseID)) as [AssignmentGroup])
    }

    public func write(response: [APIAssignmentGroup]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            AssignmentGroup.save(item, courseID: courseID, in: client, updateSubmission: include.contains(.submission), updateScoreStatistics: include.contains(.score_statistics))
        }
    }
}
