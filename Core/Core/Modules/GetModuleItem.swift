//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class GetModuleItem: APIUseCase {
    public typealias Model = ModuleItem

    public let courseID: String
    public let moduleID: String
    public let itemID: String

    public let request: GetModuleItemRequest
    public let scope: Scope
    public let cacheKey: String?

    public init(courseID: String, moduleID: String, itemID: String) {
        self.courseID = courseID
        self.moduleID = moduleID
        self.itemID = itemID
        request = GetModuleItemRequest(courseID: courseID, moduleID: moduleID, itemID: itemID, include: [.content_details])
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItem.courseID), equals: courseID),
            NSPredicate(key: #keyPath(ModuleItem.id), equals: itemID),
        ])
        scope = Scope(predicate: predicate, order: [NSSortDescriptor(key: #keyPath(ModuleItem.id), ascending: true)])
        cacheKey = request.path
    }

    public func write(response: APIModuleItem?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        let item = ModuleItem.save(response, forCourse: courseID, in: client)
        item.completionRequirement = response.completion_requirement
    }
}
