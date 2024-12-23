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

public class GetModules: UseCase {
    public typealias Model = Module
    public struct Response: Codable {
        struct Section: Codable {
            let module: APIModule
            let items: [APIModuleItem]
        }
        let sections: [Section]
    }

    public let courseID: String

    public var cacheKey: String? {
        "\(Context(.course, id: courseID).pathComponent)/modules/items"
    }

    public var scope: Scope {
        return Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(Module.courseID), courseID),
            order: [
                NSSortDescriptor(key: #keyPath(Module.position), ascending: true),
                NSSortDescriptor(key: #keyPath(Module.id), ascending: true)
            ])
    }

    public init(courseID: String) {
        self.courseID = courseID
    }

    public func reset(context: NSManagedObjectContext) {
        let all: [Model] = context.fetch(scope.predicate)
        context.delete(all)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let request = GetModulesRequest(courseID: courseID)
        environment.api.exhaust(request) { [courseID] modules, urlResponse, error in
            guard let modules = modules, error == nil else {
                completionHandler(nil, urlResponse, error)
                return
            }
            var sections: [Response.Section] = []
            var urlResponse: URLResponse?
            let loadGroup = DispatchGroup()
            loadGroup.enter()
            for module in modules {
                loadGroup.enter()
                let request = GetModuleItemsRequest(courseID: courseID, moduleID: module.id.value, include: [.content_details, .mastery_paths])
                environment.api.exhaust(request) { items, response, error in
                    defer { loadGroup.leave() }
                    urlResponse = response
                    guard let items = items, error == nil else {
                        completionHandler(nil, urlResponse, error)
                        return
                    }
                    sections.append(Response.Section(module: module, items: items))
                }
            }
            loadGroup.leave()
            loadGroup.notify(queue: .main) {
                completionHandler(Response(sections: sections), urlResponse, nil)
            }
        }
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for section in response.sections {
            let module = Module.save(section.module, forCourse: courseID, in: client)
            for item in section.items {
                let item = ModuleItem.save(item, forCourse: courseID, in: client)
                module.items.append(item)
                if let masteryPath = item.masteryPathItem {
                    module.items.append(masteryPath)
                }
            }
        }
    }
}
