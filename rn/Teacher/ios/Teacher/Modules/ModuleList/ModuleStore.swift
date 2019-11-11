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

import Foundation
import Core
import CoreData

protocol ModuleStoreDelegate: class {
    func moduleStoreDidChange(_ moduleStore: ModuleStore)
    func moduleStoreDidEncounterError(_ error: Error)
}

class ModuleStore: NSObject {
    let courseID: String
    let cache: NSFetchedResultsController<Module>
    let env: AppEnvironment
    var database: NSPersistentContainer {
        return env.database
    }
    var api: API {
        return env.api
    }
    weak var delegate: ModuleStoreDelegate?

    private(set) var isLoading: Bool = false {
        didSet {
            performUIUpdate {
                self.delegate?.moduleStoreDidChange(self)
            }
        }
    }

    private(set) var isLoadingModule: [String: Bool] = [:] {
        didSet {
            performUIUpdate {
                self.delegate?.moduleStoreDidChange(self)
            }
        }
    }

    let cacheTTL: TimeInterval = 60 * 60 * 2

    var cacheKey: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/modules"
    }

    var count: Int {
        return cache.sections?.first?.numberOfObjects ?? 0
    }

    var shouldRefresh: Bool {
        if let ttl: TTL = database.viewContext.first(where: #keyPath(TTL.key), equals: cacheKey) {
            return ttl.lastRefresh + cacheTTL < Clock.now
        }
        return true
    }

    init(courseID: String) {
        let env = AppEnvironment.shared
        self.courseID = courseID
        self.env = env
        let request = NSFetchRequest<Module>(entityName: String(describing: Module.self))
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(Module.courseID), courseID)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Module.position), ascending: true)]
        self.cache = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: env.database.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        self.cache.delegate = self
    }

    func refresh(force: Bool = false) {
        do {
            try cache.performFetch()
        } catch {
            delegate?.moduleStoreDidEncounterError(error)
        }
        let request = GetModulesRequest(courseID: courseID)
        if force || shouldRefresh {
            getModules(request, reset: true)
        }
    }

    subscript (index: Int) -> Module {
        return cache.object(at: IndexPath(row: index, section: 0))
    }

    func isLoadingItemsForModule(_ moduleID: String) -> Bool {
        return isLoadingModule[moduleID] == true
    }

    func sectionForModule(_ moduleID: String) -> Int? {
        if let module: Module = database.viewContext.first(where: #keyPath(Module.id), equals: moduleID) {
            return cache.indexPath(forObject: module)?.row
        }
        return nil
    }

    private func getModules<R>(_ request: R, reset: Bool = false) where R: APIRequestable, R.Response == [APIModule] {
        isLoading = true
        api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            self.isLoading = false
            guard let response = response else {
                performUIUpdate {
                    self.delegate?.moduleStoreDidEncounterError(error ?? NSError.internalError())
                }
                return
            }
            self.database.performBackgroundTask { context in
                if reset {
                    let modules: [Module] = context.all(where: #keyPath(Module.courseID), equals: self.courseID)
                    context.delete(modules)
                }
                Module.save(response, forCourse: self.courseID, in: context)
                let ttl: TTL = context.first(where: #keyPath(TTL.key), equals: self.cacheKey) ?? context.insert()
                ttl.key = self.cacheKey
                ttl.lastRefresh = Clock.now
                do {
                    try context.save()
                    for apiModule in response where apiModule.items == nil {
                        let request = GetModuleItemsRequest(courseID: self.courseID, moduleID: apiModule.id.value)
                        self.getItems(moduleID: apiModule.id.value, request: request)
                    }
                    if let next = urlResponse.flatMap({ request.getNext(from: $0) }) {
                        self.getModules(next)
                    }
                } catch {
                    self.delegate?.moduleStoreDidEncounterError(error)
                }
            }
        }
    }

    func getItems<R>(moduleID: String, request: R) where R: APIRequestable, R.Response == [APIModuleItem] {
        isLoadingModule[moduleID] = true
        api.makeRequest(request) { [weak self] response, urlResponse, error in
            guard let self = self else { return }
            self.isLoadingModule[moduleID] = false
            guard let response = response else {
                performUIUpdate {
                    self.delegate?.moduleStoreDidEncounterError(error ?? NSError.internalError())
                }
                return
            }
            self.database.performBackgroundTask { context in
                let modules: [Module] = context.all(where: #keyPath(Module.id), equals: moduleID)
                let module = modules.first
                for apiItem in response {
                    let item = ModuleItem.save(apiItem, forCourse: self.courseID, in: context)
                    module?.items.append(item)
                }
                do {
                    try context.save()
                } catch {
                    self.delegate?.moduleStoreDidEncounterError(error)
                }
            }
            if let next = urlResponse.flatMap({ request.getNext(from: $0) }) {
                self.getItems(moduleID: moduleID, request: next)
            }
        }
    }
}

extension ModuleStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        performUIUpdate {
            self.delegate?.moduleStoreDidChange(self)
        }
    }
}
