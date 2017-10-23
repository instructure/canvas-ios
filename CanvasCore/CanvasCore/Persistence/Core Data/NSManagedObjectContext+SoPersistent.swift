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


extension NSManagedObjectModel {
    public convenience init?(named: String, inBundle bundle: Bundle = Bundle.main) {
        guard let url = bundle.url(forResource: named, withExtension: "momd") else { return nil }
        
        self.init(contentsOf: url)
    }
}

public enum StoreResilience {
    case cache
    case userData
}

extension NSPersistentStoreCoordinator {
    func addStore(url: URL, type: String, resilience: StoreResilience, cacheReset: ()->()) throws {
        
        if resilience == .userData || type != NSSQLiteStoreType {
            try addPersistentStore(ofType: type, configurationName: nil, at: url, options: nil)
            return
        }

        
        // if it's just cache then let's remove the old store first and then create a new one
        do {
            try addPersistentStore(ofType: type, configurationName: nil, at: url, options: nil)
        } catch {
            let manager = FileManager.default
            let path = url.path
            if manager.fileExists(atPath: path) {
                try manager.removeItem(at: url)
            }
            try addPersistentStore(ofType: type, configurationName: nil, at: url, options: nil)
            cacheReset()
        }
    }
}

let pendingMergesQueue = DispatchQueue(label: "com.instructure.PendingCoreDataMerges")

extension NSManagedObjectContext {
    
    public convenience init(storeURL: URL, model: NSManagedObjectModel, resilience: StoreResilience = .cache,  concurrencyType: NSManagedObjectContextConcurrencyType = .mainQueueConcurrencyType, storeType: String = NSSQLiteStoreType, cacheReset: ()->()) throws {
        self.init(concurrencyType: concurrencyType)
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        try psc.addStore(url: storeURL, type: storeType, resilience: resilience, cacheReset: cacheReset)
        
        persistentStoreCoordinator = psc
    }
    
    var persistentStoreCoordinatorFRD: NSPersistentStoreCoordinator {
        guard let psc =
            persistentStoreCoordinator
            ?? parent?.persistentStoreCoordinator
            ?? parent?.parent?.persistentStoreCoordinator
            ?? parent?.parent?.parent?.persistentStoreCoordinator
        else {
            ❨╯°□°❩╯⌢"Seriously? Either you have no psc or you're trolling me."
        }
        
        return psc
    }
    
    public func saveFRD() throws {
        try save()
        
        var parent = self.parent
        while let p = parent {
            try p.save()
            parent = parent?.parent
        }
    }
    
    private var pointerDerivedID: String {
        return String(format: "%p", self)
    }
    
    func observeChangesFromContext(_ key: String, context: NSManagedObjectContext) {
        self.userInfo[key] = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: context, queue: nil) { [weak self] note in
            
            // move changes off the source contexts queue so we can control the locking order
            pendingMergesQueue.async { [weak self] in
                guard let sourceContext = note.object as? NSManagedObjectContext else { return }
                guard let destinationContext = self else { return }

                // the pointer address is an artibrary, but unchanging, id for the contexts
                // that we can use to guarantee that they lock in the same order every time.
                let contextsToLock = [sourceContext, destinationContext].sorted(by: { $0.pointerDerivedID < $1.pointerDerivedID })
                
                // the first lock should not block the PendingMergesQueue
                contextsToLock[0].perform {
                    contextsToLock[1].performAndWait {
                        destinationContext.mergeChanges(fromContextDidSave: note)
                    }
                }
            }
        }
    }
    
    public var syncContext: NSManagedObjectContext {
        var sync: NSManagedObjectContext!
        
        performAndWait {
            if let context = self.userInfo[SyncContextKey] as? NSManagedObjectContext { sync = context; return }
            
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.persistentStoreCoordinator = self.persistentStoreCoordinatorFRD
            context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
            
            self.observeChangesFromContext(MainContextObserverKey, context: context)
            context.perform {
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
    
    public func performChanges(_ block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}


private let errorDesc = NSLocalizedString("There was a problem reading cached data", comment: "Persistence error message")
private let errorTitle = NSLocalizedString("Read Error", comment: "tile for error reading cache")

extension NSManagedObjectContext {
    // MARK: - Fetching single items from context
    public func findOne<T: NSManagedObject>(withPredicate predicate: NSPredicate) throws -> T? {
        let fetchRequest: NSFetchRequest<T> = fetch(predicate)

        // Check if the object has been registered in the context first
        for obj in registeredObjects where !obj.isFault {
            guard let result = obj as? T, predicate.evaluate(with: result) else { continue }
            return result
        }

        return try findAll(fromFetchRequest: fetchRequest).first
    }

    public func findOne<T: NSManagedObject>(_ objectID: NSManagedObjectID) throws -> T {
        var object: T?
        performAndWait {
            object = self.object(with: objectID) as? T
        }

        guard let foundObject = object else {
            let reason = "Expected an object of type \(T.self)"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }

        return foundObject
    }

    public func findOne<T: NSManagedObject>(withValue value: Any, forKey key: String) throws -> T? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let object: T? = try findOne(withPredicate: predicate)
        return object
    }

    // MARK: - Fetching multiple items from context
    public func findAll<T: NSManagedObject>() throws -> [T] {
        let request: NSFetchRequest<T> = fetch(nil)
        let all = try fetch(request)
        return all
    }

    public func findAll<T: NSManagedObject>(fromFetchRequest request: NSFetchRequest<T>) throws -> [T] {
        let models = try fetch(request)
        return models
    }

    public func findAll<T: NSManagedObject>(matchingPredicate predicate: NSPredicate) throws -> [T] {
        print("Class being searched for: \(T.self)")
        let request = NSFetchRequest<T>(entityName: T.entityName(self))
        request.predicate = predicate
        return try findAll(fromFetchRequest: request)
    }

    public func findAll<T: NSManagedObject>(withValue value: Any, forKey key: String) throws -> [T] {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let request: NSFetchRequest<T> = fetch(predicate)
        return try findAll(fromFetchRequest: request)
    }

    public func findAll<T: NSManagedObject>(withValues values: [Any], forKey key: String) throws -> [T] {
        let predicate = NSPredicate(format: "%K in %@", key, values)
        let request: NSFetchRequest<T> = fetch(predicate)
        return try findAll(fromFetchRequest: request)
    }
    
    
    public func fetch<T: NSManagedObject>(_ predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        let request = NSFetchRequest<T>(entityName: T.entityName(self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    public func fetchedResults<T: NSManagedObject>(_ predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], sectionNameKeypath: String? = nil, propertiesToFetch: [String]? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = fetch(predicate, sortDescriptors: sortDescriptors)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 30
        if let props = propertiesToFetch { fetchRequest.propertiesToFetch = props }
        let frc = NSFetchedResultsController<T>(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeypath, cacheName: nil)
        
        return frc
    }
}
