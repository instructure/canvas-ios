//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public class GetArc: CollectionUseCase {
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
        return GetExternalToolsRequest(context: .course(courseID), includeParents: true, perPage: 100)
    }

    public var cacheKey: String? {
        return "course_\(courseID)_arc"
    }

    public init(courseID: String) {
        self.courseID = courseID
    }

    public func write(response: [APIExternalTool]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let arc = response?.first(where: { $0.arc }) {
            ExternalTool.save(arc, courseID: courseID, in: client)
        }
    }
}
