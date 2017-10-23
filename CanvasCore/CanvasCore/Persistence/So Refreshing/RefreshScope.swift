//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import CoreData




final class Refresh: NSManagedObject {
    @NSManaged fileprivate var key: String
    @NSManaged fileprivate var date: Date
}


open class RefreshScope: NSObject {
    fileprivate let context: NSManagedObjectContext
    fileprivate var refreshers: [String: Refresher] = [:]
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    internal override init() {
        guard let model = NSManagedObjectModel(named: "SoRefreshing", inBundle: Bundle(for: RefreshScope.self)) else {
            ❨╯°□°❩╯⌢"Can't load the global refresh cache model"
        }
        
        guard let libURL = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first.map(URL.init(fileURLWithPath:)) else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
        let storeURL = libURL.appendingPathComponent("GlobalSoRefreshing.sqlite")
        
        do {
            context = try NSManagedObjectContext(storeURL: storeURL, model: model, concurrencyType: .mainQueueConcurrencyType, cacheReset: {})
        } catch let e as NSError {
            ❨╯°□°❩╯⌢"Couldn't create global refresh scope.\n\(e.reportDescription)"
        }
    }
    
    open static var global = RefreshScope()

    fileprivate enum Associated {
        static var lastRefresh = "SoRefreshingLastRefresh"
    }
    
    fileprivate func synchronized<T>(_ doSomeWork: @escaping (NSManagedObjectContext) throws -> T) -> T {
        var result: T? = nil
        
        context.performAndWait {
            do {
                result = try doSomeWork(self.context)
            } catch let e as NSError {
                ❨╯°□°❩╯⌢"You're right, Brandon. Some things should just be fatal\n\(e.reportDescription)"
            }
        }
        guard let t = result else { ❨╯°□°❩╯⌢"this should never happen." }
        return t
    }
    
    fileprivate var refreshesByKey: NSMutableDictionary {
        if let lasts: NSMutableDictionary = getAssociatedObject(&Associated.lastRefresh) {
            return lasts
        }
        
        return synchronized { context in
            let lasts = NSMutableDictionary()
            let refreshes: [Refresh] = try context.findAll()
            for refresh in refreshes {
                lasts[refresh.key] = refresh
            }
            return lasts
        }
    }
    
    internal func shouldRefreshCache(_ key: String, ttl: TimeInterval) -> Bool {
        return synchronized { _ in
            return (self.lastCacheRefresh(key) + ttl) < Date()
        }
    }
    
    internal func lastCacheRefresh(_ key: String) -> Date {
        return synchronized { _ in
            return (self.refreshesByKey[key] as? Refresh)?.date ?? Date(timeIntervalSince1970: 0)
        }
    }
    
    internal func setCacheRefreshed(_ key: String, date: Date = Date()) {
        synchronized { context in
            let refresh = (self.refreshesByKey[key] as? Refresh)
                ?? Refresh(inContext: context)
            self.refreshesByKey[key] = refresh
            refresh.key = key
            refresh.date = date
            try context.saveFRD()
        }
    }
    
    open func invalidateCache(_ key: String, refresh: Bool = true) {
        setCacheRefreshed(key, date: Date(timeIntervalSince1970: 0) - 100.yearsComponents) // old and crusty

        if let refresher = refreshers[key], refresh {
            // The parameter here is whether or not this was a forced refresh. The param passed into this above function is different,
            // whether or not to actually refresh. Let's keep them disjointed!
            refresher.refresh(false)
        }
    }
    
    
    open func register(_ refresher: Refresher) {
        refreshers[refresher.cacheKey] = refresher
    }
    
    open func unregister(_ refresher: Refresher) {
        refreshers[refresher.cacheKey] = nil
    }
    
    internal func invalidateAllCaches() {
        let allRefreshes = NSFetchRequest<NSFetchRequestResult>(entityName: "Refresh")
        if #available(iOSApplicationExtension 9.0, *) {
            let batchDelete = NSBatchDeleteRequest(fetchRequest: allRefreshes)
            _ = try? context.persistentStoreCoordinator?.execute(batchDelete, with: context)
        } else {
            // Fallback on earlier versions
            for (_, refresh) in refreshesByKey {
                guard let refresh = refresh as? NSManagedObject else { continue }
                context.delete(refresh)
                try? context.saveFRD()
            }
        }
        
        refreshesByKey.removeAllObjects()
        
        for (_, refresher) in refreshers {
            refresher.refresh(false)
        }
    }
}


