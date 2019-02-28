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

public class GetAssignment: APIUseCase {
    public typealias Model = Assignment

    public let courseID: String
    public let assignmentID: String
    public let include: [GetAssignmentRequest.GetAssignmentInclude]

    public init(courseID: String, assignmentID: String, include: [GetAssignmentRequest.GetAssignmentInclude] = []) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.include = include
    }

    public var cacheKey: String {
        return "get-\(courseID)-\(assignmentID)-assignment"
    }

    public var request: GetAssignmentRequest {
        return GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID, include: include)
    }

    public var scope: Scope {
        return .where(#keyPath(Assignment.id), equals: assignmentID, orderBy: nil, naturally: true)
    }

    public func write(response: APIAssignment?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else {
            return
        }

        let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.id), response.id.value as CVarArg)
        let model: Assignment = client.fetch(predicate).first ?? client.insert()
        let updateSubmission = include.contains(.submission)
        try model.update(fromApiModel: response, in: client, updateSubmission: updateSubmission)
    }
}
