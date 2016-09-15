//
//  Model.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/30/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import CoreData
import JaSON
import ReactiveCocoa

public protocol Model {
    static func create(inContext context: NSManagedObjectContext) -> Self
    
    static func findOne(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> Self?
    static func findOne(predicate: NSPredicate, inContext context: NSManagedObjectContext) throws -> Self?
    static func findAll(request: NSFetchRequest, inContext context: NSManagedObjectContext) throws -> [Self]
    
    static func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext) -> NSFetchRequest
    
    static func fetchedResults(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], inContext context: NSManagedObjectContext) -> NSFetchedResultsController
    
    func delete(inContext context: NSManagedObjectContext)
}

public protocol SynchronizedModel: Model, Hashable {
    static func upsert(inContext context: NSManagedObjectContext)(json: JSONObject) -> SignalProducer<Self, NSError>
    
    static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate
    static func updateValues(model: Self, json: JSONObject) throws
}

extension SynchronizedModel where Self: NSManagedObject {
    public static func upsert(inContext context: NSManagedObjectContext)(json: JSONObject) -> SignalProducer<Self, NSError> {
        return SignalProducer({ observer, disposable in
            context.performBlock {
                do {
                    let model: Self = (try findOne(uniquePredicateForObject(json), inContext: context)) ?? create(inContext: context)
                    
                    try updateValues(model, json: json)
                    
                    observer.sendNext(model)
                    observer.sendCompleted()
                } catch let e as NSError {
                    observer.sendFailed(e)
                }
            }
        })
    }
}

extension Model where Self: NSManagedObject {
    public static func findAll(request: NSFetchRequest, inContext context: NSManagedObjectContext) throws -> [Self] {
        // Holiday Extravaganza TODO: Construct a meaningful error here. SoErroneous
        guard let models = try context.executeFetchRequest(request) as? [Self] else { throw NSError(domain: "com.instructure", code: -1, userInfo: [NSLocalizedDescriptionKey: "expected the type you promised to send"]) }
        return models
    }
    
    public static func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, inContext context: NSManagedObjectContext) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: entityName(context))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    public static func findOne(withValue value: AnyObject, forKey key: String, inContext context: NSManagedObjectContext) throws -> Self? {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        return try findOne(predicate, inContext: context)
    }
    
    public static func findOne(predicate: NSPredicate, inContext context: NSManagedObjectContext) throws -> Self? {
        let className = NSStringFromClass(self.classForCoder()).componentsSeparatedByString(".").last!
        let fetch = NSFetchRequest(entityName: className)
        fetch.predicate = predicate
        let matches = try context.executeFetchRequest(fetch)
        
        return matches.first as? Self
    }
    
    public static func create(inContext context: NSManagedObjectContext) -> Self {
        guard let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName(context), inManagedObjectContext: context) as? Self else { fatalError("This only works with managed objects") }
        return entity
    }
    
    private static func entityName(context: NSManagedObjectContext) -> String {
        
        let className = NSStringFromClass(object_getClass(self))
        guard let entityName = className.componentsSeparatedByString(".").last else { fatalError("ObjC runtime has failed us. Just give up and go home.") }
        
        let model = context.persistentStoreCoordinatorFRD.managedObjectModel
        if let _ = model.entitiesByName[className] {
            return className
        } else if let _ = model.entitiesByName[entityName] {
            return entityName
        } else {
            fatalError("Did you give your entity a class name? Do they match? Check again.")
        }
    }
    
    public static func fetchedResults(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor], inContext context: NSManagedObjectContext) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest(entityName: entityName(context))
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
    }

    public func delete(inContext context: NSManagedObjectContext) {
        context.deleteObject(self)
    }
}
