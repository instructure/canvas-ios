//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
