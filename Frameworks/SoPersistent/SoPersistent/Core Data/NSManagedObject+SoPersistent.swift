//
//  NSManagedObject+SoPersistent.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 1/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import Marshal
import ReactiveCocoa
import SoLazy

private let errorDesc = NSLocalizedString("There was a problem reading cached data", comment: "Persistence error message")
private let errorTitle = NSLocalizedString("Read Error", comment: "tile for error reading cache")

extension NSManagedObject {
    public static func entityName(context: NSManagedObjectContext) -> String {
        let className = NSStringFromClass(object_getClass(self))
        guard let entityName = className.componentsSeparatedByString(".").last else { ❨╯°□°❩╯⌢"ObjC runtime has failed us. Just give up and go home." }
        
        let model = context.persistentStoreCoordinatorFRD.managedObjectModel
        if let _ = model.entitiesByName[className] {
            return className
        } else if let _ = model.entitiesByName[entityName] {
            return entityName
        } else {
            ❨╯°□°❩╯⌢"Did you give your entity a class name? Do they match? Check again."
        }
    }

    public static func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName(context))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }

    public static func fetchedResults(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], sectionNameKeypath: String?, inContext context: NSManagedObjectContext) -> NSFetchedResultsController {
        let fetchRequest = fetch(predicate, sortDescriptors: sortDescriptors, inContext: context)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 30
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeypath, cacheName: nil)
        
        return frc
    }

    public func delete(inContext context: NSManagedObjectContext) {
        context.deleteObject(self)
    }
}

extension Model where Self: NSManagedObject {
    public static func findAll(context: NSManagedObjectContext) throws -> [Self] {
        let request = fetch(nil, sortDescriptors: nil, inContext: context)
        guard let all = try context.executeFetchRequest(request) as? [Self] else {
            let reason = "Expected an array of type [\(Self.self)]"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }
        return all
    }
    
    public static func findAll(request: NSFetchRequest, inContext context: NSManagedObjectContext) throws -> [Self] {
        guard let models = try context.executeFetchRequest(request) as? [Self] else {
            let reason = "Expected an array of type [\(Self.self)]"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }
        return models
    }

    public static func findAll(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> [Self] {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let request = fetch(predicate, sortDescriptors: nil, inContext: context)
        return try findAll(request, inContext: context)
    }

    public static func findAll(withValues values: [AnyObject], forKey key: String, inContext context: NSManagedObjectContext) throws -> [Self] {
        let predicate = NSPredicate(format: "%K in %@", key, values)
        let request = fetch(predicate, sortDescriptors: nil, inContext: context)
        return try findAll(request, inContext: context)
    }
    
    public static func findOne(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> Self? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        return try findOne(predicate, inContext: context)
    }
    
    public static func findOne(predicate: NSPredicate, inContext context: NSManagedObjectContext) throws -> Self? {
        let request = fetch(predicate, sortDescriptors: nil, inContext: context)
        return try findAll(request, inContext: context).first
    }
    
    public static func create(inContext context: NSManagedObjectContext) -> Self {
        guard let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName(context), inManagedObjectContext: context) as? Self else { ❨╯°□°❩╯⌢"This only works with managed objects" }
        return entity
    }
    
    public static func findOne(inContext context: NSManagedObjectContext, objectID: NSManagedObjectID) throws -> Self {
        var object: Self?
        context.performBlockAndWait {
            object = context.objectWithID(objectID) as? Self
        }
        
        guard let foundObject = object else {
            let reason = "Expected an object of type \(Self.self)"
            throw NSError(subdomain: "SoPersistent", title: errorTitle, description: errorDesc, failureReason: reason)
        }
        
        return foundObject
    }

}
