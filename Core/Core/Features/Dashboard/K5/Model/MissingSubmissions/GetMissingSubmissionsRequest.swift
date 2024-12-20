//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/users.html#method.users.missing_submissions
public struct GetMissingSubmissionsRequest: APIRequestable {
    public typealias Response = [APIAssignment]
    public enum Include: String {
        case planner_overrides
        case course
    }

    public var path: String { "users/\(userId)/missing_submissions" }
    public var query: [APIQueryItem] {[
        .array("course_ids", courseIds),
        .array("include", includes.map { $0.rawValue }),
        .array("filter", ["current_grading_period", "submittable"])
    ]}

    private let userId: String
    private let courseIds: [String]
    private let includes: [Include]

    public init(userId: String = "self", courseIds: [String] = [], includes: [Include] = []) {
        self.userId = userId
        self.courseIds = courseIds
        self.includes = includes
    }
}
