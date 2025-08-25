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

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.show
public struct GetAssignmentRequest: APIRequestable {
    public typealias Response = APIAssignment

    public enum Include: String, CaseIterable {
        case submission
        case overrides
        case score_statistics
        case can_submit
        case observed_users
    }

    let courseID: String
    let assignmentID: String
    let include: [Include]
    let allDates: Bool?

    init(courseID: String, assignmentID: String, allDates: Bool? = nil, include: [Include]) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.include = include
        self.allDates = allDates
    }

    public var path: String {
        let context = Context(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        var include = self.include
        include.append(.can_submit)
        query.append(.array("include", include.map { $0.rawValue }))
        if AppEnvironment.shared.app == .teacher || allDates == true {
            query.append(.value("all_dates", "true"))
        }
        return query
    }
}
