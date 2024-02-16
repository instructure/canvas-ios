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
    let gradedOnly: Bool

    private let include: [GetAssignmentGroupsRequest.Include] = [ .assignments, .observed_users, .submission, .score_statistics, .discussion_topic, .all_dates ]

    public init(courseID: String, gradingPeriodID: String? = nil, gradedOnly: Bool = false) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.gradedOnly = gradedOnly
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

    private var predicate: NSPredicate {
        var predicate = NSPredicate(key: #keyPath(Assignment.assignmentGroup.courseID), equals: courseID)

        if gradedOnly {
            predicate = predicate.and(NSPredicate(format: "%K != %@", #keyPath(Assignment.gradingTypeRaw), "not_graded"))
        }

        return predicate
    }

    public var scope: Scope { Scope(
        predicate: predicate,
        order: [
            NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.position), ascending: true),
            NSSortDescriptor(key: #keyPath(Assignment.assignmentGroup.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Assignment.dueAtSortNilsAtBottom), ascending: true),
            NSSortDescriptor(key: #keyPath(Assignment.position), ascending: true),
            NSSortDescriptor(key: #keyPath(Assignment.name), ascending: true, naturally: true),
        ],
        sectionNameKeyPath: #keyPath(Assignment.assignmentGroup.position)
    ) }

    public func reset(context: NSManagedObjectContext) {
        context.delete(context.fetch(NSPredicate(key: #keyPath(AssignmentGroup.courseID), equals: courseID)) as [AssignmentGroup])
    }

    public func write(response: [APIAssignmentGroup]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        // For teacher roles this API doesn't return any submissions
        let updateSubmission = AppEnvironment.shared.app != .teacher && include.contains(.submission)
        response?.forEach { item in
            AssignmentGroup.save(item, courseID: courseID, in: client, updateSubmission: updateSubmission, updateScoreStatistics: include.contains(.score_statistics))
        }
    }
}
