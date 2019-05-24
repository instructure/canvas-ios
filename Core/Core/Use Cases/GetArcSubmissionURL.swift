//
// Copyright (C) 2019-present Instructure, Inc.
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

public class GetArc: APIUseCase {
    public typealias Response = [APIExternalTool]
    public typealias Model = ExternalTool

    public let courseID: String
    public var scope: Scope {
        let course = NSPredicate(format: "%K == %@", #keyPath(ExternalTool.courseID), courseID)
        let arc = NSPredicate(format: "%K == true", #keyPath(ExternalTool.arc))
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [course, arc])
        let order = NSSortDescriptor(key: #keyPath(ExternalTool.id), ascending: true)
        return Scope(predicate: predicate, order: [order])
    }

    public var request: GetExternalToolsRequest {
        return GetExternalToolsRequest(context: ContextModel(.course, id: courseID), includeParents: true)
    }

    public var cacheKey: String? {
        return "\(courseID)-arc-id"
    }

    public init(courseID: String) {
        self.courseID = courseID
    }

    public func write(response: [APIExternalTool]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        guard let response = response else { return }
        ExternalTool.save(response, courseID: courseID, in: client)
    }
}
