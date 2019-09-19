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

public struct GetAssignmentGroupsRequest: APIRequestable {
    public typealias Response = [APIAssignmentGroup]

    public enum Include: String {
        case assignments
    }

    let courseID: String
    let include: [Include]

    init(courseID: String, include: [Include] = []) {
        self.courseID = courseID
        self.include = include
    }

    public var path: String {
        return "courses/\(courseID)/assignment_groups"
    }

    public var query: [APIQueryItem] {
        var q: [APIQueryItem] = [ .value("per_page", "99") ]

        if !include.isEmpty {
            q.append( .array("include", include.map { $0.rawValue }) )
        }
        return q
    }
}
