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

// https://canvas.instructure.com/doc/api/submissions.html#method.submissions_api.index
public struct GetSubmissionsRequest: APIRequestable {
    public typealias Response = [APISubmission]

    enum Include: String, CaseIterable {
        case assignment
        case group
        case rubric_assessment
        case sub_assignment_submissions
        case submission_comments
        case submission_history
        case total_scores
        case user
    }

    let context: Context
    let assignmentID: String
    let grouped: Bool?
    let include: [Include]

    init(context: Context, assignmentID: String, grouped: Bool? = nil, include: [Include] = []) {
        self.context = context
        self.assignmentID = assignmentID
        self.grouped = grouped
        self.include = include
    }

    public var path: String {
        return "\(context.pathComponent)/assignments/\(assignmentID)/submissions"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .perPage(100),
            .include(include.map { $0.rawValue })
        ]
        if let grouped = grouped {
            query.append(.bool("grouped", grouped))
        }
        return query
    }
}
