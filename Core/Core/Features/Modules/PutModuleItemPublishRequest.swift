//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct PutModuleItemPublishRequest: APIRequestable {
    typealias Response = APIModuleItem
    struct Body: CodableEquatable {
        struct ModuleItem: CodableEquatable {
            let published: Bool
        }
        let module_item: ModuleItem
    }

    let path: String
    let body: Body?
    let method: APIMethod = .put

    private let courseId: String
    private let moduleItemId: String

    init(
        courseId: String,
        moduleId: String,
        moduleItemId: String,
        action: ModulePublishAction
    ) {
        self.courseId = courseId
        self.moduleItemId = moduleItemId
        path = "courses/\(courseId)/modules/\(moduleId)/items/\(moduleItemId)"
        body = Body(module_item: .init(published: action.isPublish))
    }
}

struct PutModuleItemPublishState: APIUseCase {
    public typealias Model = ModuleItem

    let cacheKey: String? = nil
    let request: PutModuleItemPublishRequest
    var scope: Scope { Scope(predicate: predicate, order: []) }

    private let action: ModulePublishAction
    private let predicate: NSPredicate

    init(
        courseId: String,
        moduleId: String,
        moduleItemId: String,
        action: ModulePublishAction
    ) {
        self.action = action
        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(ModuleItem.courseID), equals: courseId),
            NSPredicate(key: #keyPath(ModuleItem.id), equals: moduleItemId)
        ])

        request = PutModuleItemPublishRequest(
            courseId: courseId,
            moduleId: moduleId,
            moduleItemId: moduleItemId,
            action: action
        )
    }

    func write(
        response: APIModuleItem?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let model: ModuleItem = client.fetch(predicate).first else {
            return
        }

        model.published = action.isPublish
    }
}
