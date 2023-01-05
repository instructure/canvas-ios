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

import Foundation

public struct APIAssignmentGroup: Codable, Equatable {
    let id: ID
    let name: String
    let position: Int
    var assignments: [APIAssignment]?
}

#if DEBUG
extension APIAssignmentGroup {
    public static func make(
        id: ID = "1",
        name: String = "Assignment Group A",
        position: Int = 1,
        assignments: [APIAssignment]? = nil
        ) -> APIAssignmentGroup {
        return APIAssignmentGroup(
            id: id,
            name: name,
            position: position,
            assignments: assignments
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/assignment_groups.html#method.assignment_groups.index
public struct GetAssignmentGroupsRequest: APIRequestable {
    public typealias Response = [APIAssignmentGroup]

    public enum Include: String, CaseIterable {
        case assignments, discussion_topic, observed_users, submission, score_statistics, all_dates
    }

    let courseID: String
    let gradingPeriodID: String?
    let include: [Include]
    let perPage: Int?

    init(courseID: String, gradingPeriodID: String? = nil, include: [Include] = [], perPage: Int? = nil) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        return "courses/\(courseID)/assignment_groups"
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .perPage(perPage),
            .optionalValue("grading_period_id", gradingPeriodID),
        ]
    }
}
