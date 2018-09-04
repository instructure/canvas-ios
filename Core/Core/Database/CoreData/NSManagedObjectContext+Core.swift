//
// Copyright (C) 2018-present Instructure, Inc.
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

extension NSManagedObjectContext: DatabaseClient {
    public func delete<T>(_ object: T) {
        if let managedObject = object as? NSManagedObject {
            delete(managedObject)
        }
    }

    public func fetchedResultsController<T>(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]?, sectionNameKeyPath: String?) -> FetchedResultsController<T> {
        let name = String(describing: T.self)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        return CoreDataFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath)
    }

    public func insert<T>() -> T {
        let name = String(describing: T.self)
        if let result = NSEntityDescription.insertNewObject(forEntityName: name, into: self) as? T {
            return result
        } else {
            fatalError()
        }
    }

    public func fetch<T>(_ predicate: NSPredicate) -> [T] {
        let name = String(describing: T.self)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = predicate
        return (try? fetch(request)) as? [T] ?? []
    }
}
