//
//  ManagedObjectCountObserver.swift
//  SoPersistent
//
//  Created by Ben Kraus on 5/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public class ManagedObjectCountObserver<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    public let predicate: NSPredicate
    public let context: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController

    public let objectCountUpdated: (Int)->Void

    public var currentCount: Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }

    public init(predicate: NSPredicate, inContext context: NSManagedObjectContext, objectCountUpdated: (Int)->Void) {
        self.predicate = predicate
        self.context = context

        let fetchReqeust = T.fetch(predicate, sortDescriptors: [], inContext: context)
        // There is a bug in Core Data with the ManagedObjectIDResultType where the count won't go down if you delete the object -
        // the FRC doesn't know to remove the object id in it's cache, if a given object is deleted. So - we use the default result
        // type to fetch the object itself, but don't include property values so it doesn't inlcude much additional memory overhead,
        // as noted in the docs: 
        //
        // "If includesPropertyValues is false, then Core Data fetches only the object ID information for the matching records—it does not populate the row cache."
        fetchReqeust.includesPropertyValues = false
        let frc = NSFetchedResultsController(fetchRequest: fetchReqeust, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        self.fetchedResultsController = frc

        self.objectCountUpdated = objectCountUpdated

        super.init()

        self.fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
            self.objectCountUpdated(fetchedResultsController.sections?.first?.numberOfObjects ?? 0)
        } catch let e {
            print(e)
        }
    }

    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        let count = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
        self.objectCountUpdated(count)
    }
}
