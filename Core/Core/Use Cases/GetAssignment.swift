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

import CoreData
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

    public var cacheKey: String? {
        return "get-\(courseID)-\(assignmentID)-assignment"
    }

    public var request: GetAssignmentRequest {
        return GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID, include: include)
    }

    public var scope: Scope {
        return .where(#keyPath(Assignment.id), equals: assignmentID)
    }

    public func write(response: APIAssignment?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        let model: Assignment = client.fetch(scope.predicate).first ?? client.insert()
        let updateSubmission = include.contains(.submission)
        model.update(fromApiModel: response, in: client, updateSubmission: updateSubmission)
    }
}
