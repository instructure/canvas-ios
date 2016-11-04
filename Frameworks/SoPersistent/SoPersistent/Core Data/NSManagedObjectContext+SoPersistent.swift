
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


private let errorDesc = NSLocalizedString("There was a problem reading cached data", comment: "Persistence error message")
private let errorTitle = NSLocalizedString("Read Error", comment: "tile for error reading cache")

extension NSManagedObjectContext {
    // MARK: - Fetching single items from context
    public func findOne<T: NSManagedObject>(withPredicate predicate: NSPredicate) throws -> T? {
        let fetchRequest = T.fetch(predicate, inContext: self)

        // Check if the object has been registered in the context first
        for obj in registeredObjects where !obj.fault {
            guard let result = obj as? T where predicate.evaluateWithObject(result) else { continue }
            return result
        }

        return try findAll(fromFetchRequest: fetchRequest).first
    }

    public func findOne<T: NSManagedObject>(objectID: NSManagedObjectID) throws -> T {
        var object: T?
        performBlockAndWait {
            object = self.objectWithID(objectID) as? T
        }

        guard let foundObject = object else {
            let reason = "Expected an object of type \(T.self)"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }

        return foundObject
    }

    public func findOne<T: NSManagedObject>(withValue value: AnyObject, forKey key: String) throws -> T? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let object: T? = try findOne(withPredicate: predicate)
        return object
    }

    // MARK: - Fetching multiple items from context
    public func findAll<T: NSManagedObject>() throws -> [T] {
        let request = T.fetch(nil, inContext: self)
        guard let all = try executeFetchRequest(request) as? [T] else {
            let reason = "Expected an array of type [\(T.self)]"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }
        return all
    }

    public func findAll<T: NSManagedObject>(fromFetchRequest request: NSFetchRequest) throws -> [T] {
        guard let models = try executeFetchRequest(request) as? [T] else {
            let reason = "Expected an array of type [\(T.self)]"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }
        return models
    }

    public func findAll<T: NSManagedObject>(withValue value: AnyObject, forKey key: String) throws -> [T] {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let request = T.fetch(predicate, inContext: self)
        return try findAll(fromFetchRequest: request)
    }

    public func findAll<T: NSManagedObject>(withValues values: [AnyObject], forKey key: String) throws -> [T] {
        let predicate = NSPredicate(format: "%K in %@", key, values)
        let request = T.fetch(predicate, inContext: self)
        return try findAll(fromFetchRequest: request)
    }
}