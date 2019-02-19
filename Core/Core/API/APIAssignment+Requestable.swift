//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.show
public struct GetAssignmentRequest: APIRequestable {
    public typealias Response = APIAssignment

    let courseID: String
    let assignmentID: String
    let include: [GetAssignmentInclude]

    public enum GetAssignmentInclude: String {
        case submission
    }

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []

        if !include.isEmpty {
            query.append(.array("include", include.map { $0.rawValue }))
        }
        return query
    }
}

struct APIAssignmentParameters: Codable, Equatable {
    let name: String
    let description: String?
    let points_possible: Double
    let due_at: Date?
    let submission_types: [SubmissionType]
    let allowed_extensions: [String]
    let published: Bool
    let grading_type: GradingType
    let lock_at: Date?
    let unlock_at: Date?
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.create
struct PostAssignmentRequest: APIRequestable {
    typealias Response = APIAssignment
    struct Body: Codable, Equatable {
        let assignment: APIAssignmentParameters
    }

    let courseID: String

    let body: Body?
    let method = APIMethod.post
    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/assignments"
    }
}

// https://canvas.instructure.com/doc/api/assignments.html#method.assignments_api.index
public struct GetAssignmentsRequest: APIRequestable {
    public typealias Response = [APIAssignment]

    let courseID: String

    public var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/assignments?per_page=100"
    }
}
