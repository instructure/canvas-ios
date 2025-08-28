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

// https://canvas.instructure.com/doc/api/assignment_groups.html#method.assignment_groups.index
public struct GetAssignmentGroupsRequest: APIRequestable {
    public typealias Response = [APIAssignmentGroup]

    public enum Include: String, CaseIterable {
        case all_dates
        case assignments
        case checkpoints
        case discussion_topic
        case observed_users
        case score_statistics
        case sub_assignment_submissions
        case submission
    }

    let courseID: String
    let gradingPeriodID: String?
    let include: [Include]
    let perPage: Int?

    init(
        courseID: String,
        gradingPeriodID: String? = nil,
        include: [Include] = Include.allCases,
        perPage: Int? = nil
    ) {
        self.courseID = courseID
        self.gradingPeriodID = gradingPeriodID
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        "courses/\(courseID)/assignment_groups"
    }

    public var query: [APIQueryItem] {
        [
            .include(include.map { $0.rawValue }),
            .perPage(perPage),
            .optionalValue("grading_period_id", gradingPeriodID)
        ]
    }
}
