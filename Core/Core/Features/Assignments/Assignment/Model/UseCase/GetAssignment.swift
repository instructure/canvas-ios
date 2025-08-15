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
import CoreData

public class GetAssignment: APIUseCase {
    public typealias Model = Assignment

    public let courseID: String
    public let assignmentID: String
    public let include: [GetAssignmentRequest.Include]

    public init(courseID: String, assignmentID: String, include: [GetAssignmentRequest.Include] = []) {
        self.courseID = courseID
        self.assignmentID = assignmentID
        self.include = include
    }

    public var cacheKey: String? {
        return "get-\(courseID)-\(assignmentID)-assignment-\(include.map { $0.rawValue } .sorted().joined())"
    }

    public var request: GetAssignmentRequest {
        return GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID, include: include)
    }

    public var scope: Scope {
        return .where((\Assignment.id).string, equals: assignmentID)
    }

    public func write(response: APIAssignment?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else {
            return
        }

        let model: Assignment = client.fetch(scope.predicate).first ?? client.insert()
        let updateSubmission = include.contains(.submission)
        let updateScoreStatistics = include.contains(.score_statistics)
        model.update(fromApiModel: response, in: client, updateSubmission: updateSubmission, updateScoreStatistics: updateScoreStatistics)
    }
}
