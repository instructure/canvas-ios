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

public class GetAssignments: CollectionUseCase {
    public typealias Model = Assignment

    public let courseID: String

    public init(courseID: String) {
        self.courseID = courseID
    }

    public var cacheKey: String {
        return "get-\(courseID)-assignments"
    }

    public var request: GetAssignmentsRequest {
        return GetAssignmentsRequest(courseID: courseID)
    }

    public var scope: Scope {
        return .where(#keyPath(Assignment.courseID), equals: courseID, orderBy: nil, naturally: true)
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else {
            return
        }

        for item in response {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(Assignment.htmlURL), item.html_url as CVarArg)
            let model: Assignment = client.fetch(predicate).first ?? client.insert()
            try model.update(fromApiModel: item, in: client, updateSubmission: false)
        }
    }
}
