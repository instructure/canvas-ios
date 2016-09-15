//
//  NSManagedObjectContext+CakeBox.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import CoreData

extension NSManagedObjectModel {
    public convenience init?(named: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) {
        guard let url = bundle.URLForResource(named, withExtension: "momd") else { return nil }
        
        self.init(contentsOfURL: url)
    }
}

extension NSManagedObjectContext {
    public convenience init(storeURL: NSURL, model: NSManagedObjectModel, concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) throws {
        self.init(concurrencyType: concurrencyType)
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        // Holiday Extravaganza TODO: Migration?
        try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        
        persistentStoreCoordinator = psc
    }
    
    var persistentStoreCoordinatorFRD: NSPersistentStoreCoordinator {
        guard let psc =
            persistentStoreCoordinator
            ?? parentContext?.persistentStoreCoordinator
            ?? parentContext?.parentContext?.persistentStoreCoordinator
            ?? parentContext?.parentContext?.parentContext?.persistentStoreCoordinator
        else {
            fatalError("Seriously? Either you have no psc or you're trolling me.")
        }
        
        return psc
    }
    
    func saveFRD() throws {
        try save()
        
        var parent = self.parentContext
        while let p = parent {
            try p.save()
            parent = parent?.parentContext
        }
    }
    
    var syncContext: NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self
        return context
    }
}
