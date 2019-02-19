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

class GetPaginatedAssignments: PaginatedUseCase<GetAssignmentsRequest, Assignment> {
    let courseID: String

    init(courseID: String, env: AppEnvironment, force: Bool = false) {
        self.courseID = courseID
        let request = GetAssignmentsRequest(courseID: courseID)
        super.init(api: env.api, database: env.database, request: request)
    }

    override var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Assignment.courseID), courseID)
    }

    override func predicate(forItem item: APIAssignment) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(Assignment.htmlURL), item.html_url as CVarArg)
    }

    override func updateModel(_ model: Assignment, using item: APIAssignment, in client: PersistenceClient) throws {
        try model.update(fromApiModel: item, in: client, updateSubmission: false)
    }
}

public class GetAssignments: OperationSet {
    public init(courseID: String, force: Bool = false, env: AppEnvironment) {
        let paginated = GetPaginatedAssignments(courseID: courseID, env: env)
        let ttl = TTLOperation(key: "get-\(courseID)-assignments", database: env.database, operation: paginated, force: force)
        super.init(operations: [ttl])
    }
}
