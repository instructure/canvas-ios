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
    
    

import Foundation
import CoreData

open class ManagedObjectCountObserver<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
    open let predicate: NSPredicate
    open let context: NSManagedObjectContext
    fileprivate let fetchedResultsController: NSFetchedResultsController<T>

    open let objectCountUpdated: (Int)->Void

    open var currentCount: Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }

    public init(predicate: NSPredicate, inContext context: NSManagedObjectContext, objectCountUpdated: @escaping (Int)->Void) {
        self.predicate = predicate
        self.context = context

        let fetchReqeust: NSFetchRequest<T> = context.fetch(predicate, sortDescriptors: [])
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

    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let count = fetchedResultsController.sections?.first?.numberOfObjects ?? 0
        self.objectCountUpdated(count)
    }
}
