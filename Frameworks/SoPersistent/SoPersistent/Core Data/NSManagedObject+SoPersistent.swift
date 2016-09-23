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

private let errorDesc = NSLocalizedString("There was a problem reading cached data", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.SoPersistent")!, value: "", comment: "Persistence error message")
private let errorTitle = NSLocalizedString("Read Error", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.SoPersistent")!, value: "", comment: "tile for error reading cache")

extension NSManagedObject {
    public convenience init(inContext context: NSManagedObjectContext) {
        let entityName = self.dynamicType.entityName(context)
        let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public static func create<T>(inContext context: NSManagedObjectContext) -> T {
        guard let entity = NSEntityDescription.insertNewObjectForEntityForName(entityName(context), inManagedObjectContext: context) as? T else { ❨╯°□°❩╯⌢"This only works with managed objects" }
        return entity
    }

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

    public static func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]? = nil, inContext context: NSManagedObjectContext) -> NSFetchRequest {
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
