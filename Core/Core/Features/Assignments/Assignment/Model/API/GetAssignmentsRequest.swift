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

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
public struct GetAssignmentsRequest: APIRequestable {
    public enum OrderBy: String {
        case position, name
    }

    public enum Include: String {
        case overrides
        case discussion_topic
        case observed_users
        case submission
        case all_dates
        case score_statistics
    }

    public typealias Response = [APIAssignment]

    let courseID: String
    let assignmentGroupID: String?
    let orderBy: OrderBy?
    let assignmentIDs: [String]?
    let include: [Include]
    let perPage: Int?

    public init(
        courseID: String,
        assignmentGroupID: String? = nil,
        orderBy: OrderBy? = .position,
        assignmentIDs: [String]? = nil,
        include: [Include] = [],
        perPage: Int? = nil
    ) {
        self.courseID = courseID
        self.assignmentGroupID = assignmentGroupID
        self.orderBy = orderBy
        self.assignmentIDs = assignmentIDs
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        if let assignmentGroupID = assignmentGroupID {
            return "\(context.pathComponent)/assignment_groups/\(assignmentGroupID)/assignments"
        }
        return "\(context.pathComponent)/assignments"
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .optionalValue("order_by", orderBy?.rawValue),
            .array("assignment_ids", assignmentIDs ?? []),
            .perPage(perPage)
        ]
    }
}
