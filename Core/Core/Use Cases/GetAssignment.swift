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

public class GetAssignment: DetailUseCase<GetAssignmentRequest, Assignment> {
    let assignmentID: String
    let includes: [GetAssignmentRequest.GetAssignmentInclude]

    public init(courseID: String, assignmentID: String, include: [GetAssignmentRequest.GetAssignmentInclude] = [], env: AppEnvironment = .shared) {
        self.assignmentID = assignmentID
        self.includes = include
        let request = GetAssignmentRequest(courseID: courseID, assignmentID: assignmentID, include: include)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Assignment.id), assignmentID)
    }

    override func updateModel(_ model: Assignment, using item: APIAssignment, in client: PersistenceClient) throws {
        try model.update(fromApiModel: item, in: client, updateSubmission: includes.contains(.submission))
    }
}
