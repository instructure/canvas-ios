//
//  NSManagedObjectContext+SoPersistent.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import CoreData
import SoLazy

extension NSManagedObjectModel {
    public convenience init?(named: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) {
        guard let url = bundle.URLForResource(named, withExtension: "momd") else { return nil }
        
        self.init(contentsOfURL: url)
    }
}

public enum StoreResilience {
    case cache
    case userData
}

extension NSPersistentStoreCoordinator {
    func addStore(url url: NSURL, type: String, resilience: StoreResilience, cacheReset: ()->()) throws {
        
        if resilience == .userData || type != NSSQLiteStoreType {
            try addPersistentStoreWithType(type, configuration: nil, URL: url, options: nil)
            return
        }

        
        // if it's just cache then let's remove the old store first and then create a new one
        do {
            try addPersistentStoreWithType(type, configuration: nil, URL: url, options: nil)
        } catch {
            let manager = NSFileManager.defaultManager()
            if let path = url.path where manager.fileExistsAtPath(path) {
                try manager.removeItemAtURL(url)
            }
            try addPersistentStoreWithType(type, configuration: nil, URL: url, options: nil)
            cacheReset()
        }
    }
}

extension NSManagedObjectContext {
    
    public convenience init(storeURL: NSURL, model: NSManagedObjectModel, resilience: StoreResilience = .cache,  concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType, storeType: String = NSSQLiteStoreType, cacheReset: ()->()) throws {
        self.init(concurrencyType: concurrencyType)
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        try psc.addStore(url: storeURL, type: storeType, resilience: resilience, cacheReset: cacheReset)
        
        persistentStoreCoordinator = psc
    }
    
    var persistentStoreCoordinatorFRD: NSPersistentStoreCoordinator {
        guard let psc =
            persistentStoreCoordinator
            ?? parentContext?.persistentStoreCoordinator
            ?? parentContext?.parentContext?.persistentStoreCoordinator
            ?? parentContext?.parentContext?.parentContext?.persistentStoreCoordinator
        else {
            ❨╯°□°❩╯⌢"Seriously? Either you have no psc or you're trolling me."
        }
        
        return psc
    }
    
    public func saveFRD() throws {
        try save()
        
        var parent = self.parentContext
        while let p = parent {
            try p.save()
            parent = parent?.parentContext
        }
    }
    
    func observeChangesFromContext(key: String, context: NSManagedObjectContext) {
        self.userInfo[key] = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: context, queue: nil) { [weak self] note in
            self?.performBlockAndWait {
                self?.mergeChangesFromContextDidSaveNotification(note)
            }
        }
    }
    
    public var syncContext: NSManagedObjectContext {
        var sync: NSManagedObjectContext!
        
        performBlockAndWait {
            if let context = self.userInfo[SyncContextKey] as? NSManagedObjectContext { sync = context; return }
            
            let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentStoreCoordinatorFRD
            
            self.observeChangesFromContext(MainContextObserverKey, context: context)
            context.performBlock {
                context.observeChangesFromContext(MainContextObserverKey, context: self)
            }
            
            self.userInfo[SyncContextKey] = context
            sync = context
        }
        
        return sync
    }
}

private let SyncContextKey = "YeOldeSyncContext"
private let MainContextObserverKey = "YeOldeMainContextObserver"

extension NSManagedObjectContext {
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    public func performChanges(block: () -> ()) {
        performBlock {
            block()
            self.saveOrRollback()
        }
    }
}