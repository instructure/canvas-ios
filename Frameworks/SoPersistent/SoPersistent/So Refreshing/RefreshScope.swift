//
//  Refresher.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
import TooLegit
import SoLazy


final class Refresh: NSManagedObject, Model {
    @NSManaged private var key: String
    @NSManaged private var date: NSDate
}


public class RefreshScope: NSObject {
    private let context: NSManagedObjectContext
    private var refreshers: [String: Refresher] = [:]
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    internal override init() {
        guard let model = NSManagedObjectModel(named: "SoRefreshing", inBundle: NSBundle(forClass: RefreshScope.self)) else {
            ❨╯°□°❩╯⌢"Can't load the global refresh cache model"
        }
        
        guard let libURL = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true).first.map(NSURL.init(fileURLWithPath:)) else { ❨╯°□°❩╯⌢"GASP! There were no user library search paths" }
        let storeURL = libURL.URLByAppendingPathComponent("GlobalSoRefreshing.sqlite")
        
        do {
            context = try NSManagedObjectContext(storeURL: storeURL, model: model, concurrencyType: .MainQueueConcurrencyType, cacheReset: {})
        } catch let e as NSError {
            ❨╯°□°❩╯⌢"Couldn't create global refresh scope.\n\(e.reportDescription)"
        }
    }
    
    public static var global = RefreshScope()

    private enum Associated {
        static var lastRefresh = "SoRefreshingLastRefresh"
    }
    
    private func synchronized<T>(doSomeWork: (NSManagedObjectContext) throws -> T) -> T {
        var result: T? = nil
        
        context.performBlockAndWait {
            do {
                result = try doSomeWork(self.context)
            } catch let e as NSError {
                ❨╯°□°❩╯⌢"You're right, Brandon. Some things should just be fatal\n\(e.reportDescription)"
            }
        }
        guard let t = result else { ❨╯°□°❩╯⌢"this should never happen." }
        return t
    }
    
    private var refreshesByKey: NSMutableDictionary {
        if let lasts: NSMutableDictionary = getAssociatedObject(&Associated.lastRefresh) {
            return lasts
        }
        
        return synchronized { context in
            let lasts = NSMutableDictionary()
            let refreshes = try Refresh.findAll(context)
            for refresh in refreshes {
                lasts[refresh.key] = refresh
            }
            return lasts
        }
    }
    
    internal func shouldRefreshCache(key: String, ttl: NSTimeInterval) -> Bool {
        return synchronized { _ in
            return (self.lastCacheRefresh(key) + ttl) < NSDate()
        }
    }
    
    internal func lastCacheRefresh(key: String) -> NSDate {
        return synchronized { _ in
            return (self.refreshesByKey[key] as? Refresh)?.date ?? NSDate(timeIntervalSince1970: 0)
        }
    }
    
    internal func setCacheRefreshed(key: String, date: NSDate = NSDate()) {
        synchronized { context in
            let refresh = (self.refreshesByKey[key] as? Refresh)
                ?? Refresh.create(inContext: context)
            self.refreshesByKey[key] = refresh
            refresh.key = key
            refresh.date = date
            try context.saveFRD()
        }
    }
    
    public func invalidateCache(key: String, refresh: Bool = true) {
        setCacheRefreshed(key, date: NSDate(timeIntervalSince1970: 0) - 100.yearsComponents) // old and crusty
        
        if let refresher = refreshers[key] where refresh {
            refresher.refresh(false)
        }
    }
    
    
    public func register(refresher: Refresher) {
        refreshers[refresher.cacheKey] = refresher
    }
    
    public func unregister(refresher: Refresher) {
        refreshers[refresher.cacheKey] = nil
    }
    
    internal func invalidateAllCaches() {
        let allRefreshes = NSFetchRequest(entityName: "Refresh")
        if #available(iOSApplicationExtension 9.0, *) {
            let batchDelete = NSBatchDeleteRequest(fetchRequest: allRefreshes)
            try? context.persistentStoreCoordinator?.executeRequest(batchDelete, withContext: context)
        } else {
            // Fallback on earlier versions
            for (_, refresh) in refreshesByKey {
                guard let refresh = refresh as? NSManagedObject else { continue }
                context.deleteObject(refresh)
                try? context.saveFRD()
            }
        }
        
        refreshesByKey.removeAllObjects()
        
        for (_, refresher) in refreshers {
            refresher.refresh(false)
        }
    }
}


