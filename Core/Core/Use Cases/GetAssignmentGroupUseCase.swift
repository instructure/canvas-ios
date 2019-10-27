//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class GetAssignmentGroups: CollectionUseCase {
    public typealias Model = AssignmentGroup
    public let courseID: String
    public let gradingPeriodID: String?
    let include: [GetAssignmentGroupsRequest.Include]
    let scopeAssignmentsToStudent: Bool

    public init(courseID: String, gradingPeriodID: String?, include: [GetAssignmentGroupsRequest.Include] = [], scopeAssignmentsToStudent: Bool = true) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.include = include
        self.scopeAssignmentsToStudent = scopeAssignmentsToStudent
    }

    public var cacheKey: String? {
//        this should not cache, each time it needs to update assignments
//        ```
//        assignment.assignmentGroupPosition = AssignmentGroup.position
//        assignment.gradingPeriodID = gradingPeriodID
//        ```

        return nil
    }

    public var scope: Scope {
        return Scope.where(#keyPath(AssignmentGroup.courseID), equals: courseID, orderBy: #keyPath(AssignmentGroup.position), ascending: true, naturally: false)
    }

    public var request: GetAssignmentGroupsRequest {
        return GetAssignmentGroupsRequest(courseID: courseID, gradingPeriodID: gradingPeriodID, include: include, scopeAssignmentsToStudent: scopeAssignmentsToStudent)
    }

    public func write(response: [APIAssignmentGroup]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for item in response {
            AssignmentGroup.save(item, courseID: courseID, in: client)

            //  needed for assignmentList(Student) and grades(Parent)
            for a in item.assignments ?? [] {
                let assignmentPredicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), a.id.value)
                let assignment: Assignment = client.fetch(assignmentPredicate).first ?? client.insert()
                assignment.update(fromApiModel: a, in: client, updateSubmission: false)
                assignment.assignmentGroupPosition = item.position
                assignment.gradingPeriodID = gradingPeriodID
            }
        }
    }
}
