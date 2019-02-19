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

// https://canvas.instructure.com/doc/api/assignments.html#method.assignment_overrides.create
struct CreateAssignmentOverrideRequest: APIRequestable {
    typealias Response = APIAssignmentOverride
    struct Body: Codable, Equatable {
        struct AssignmentOverride: Codable, Equatable {
            let title: String
        }

        let assignment_override: AssignmentOverride
    }

    let courseID: String
    let assignmentID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/assignments/\(assignmentID)/overrides"
    }
}
