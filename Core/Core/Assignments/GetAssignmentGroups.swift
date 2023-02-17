//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public class GetAssignmentGroups: APIUseCase {
    public typealias Model = AssignmentGroup

    let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String? {
        "courses/\(courseID)/assignment_groups"
    }

    public var request: GetAssignmentGroupsRequest { GetAssignmentGroupsRequest(
        courseID: courseID,
        include: GetAssignmentGroupsRequest.Include.allCases,
        perPage: 100
    ) }

    public var scope: Scope {
        return .where(#keyPath(AssignmentGroup.courseID), equals: courseID)
    }

    public func write(response: [APIAssignmentGroup]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            AssignmentGroup.save(item, courseID: courseID, in: client, updateSubmission: true, updateScoreStatistics: true)
        }
    }
}
