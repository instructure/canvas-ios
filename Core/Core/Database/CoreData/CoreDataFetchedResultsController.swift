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

class CoreDataFetchedResultsController<ResultType>: FetchedResultsController<ResultType>, NSFetchedResultsControllerDelegate {
    private let frc: NSFetchedResultsController<NSFetchRequestResult>

    init(fetchRequest: NSFetchRequest<NSFetchRequestResult>, managedObjectContext: NSManagedObjectContext, sectionNameKeyPath: String?) {
        frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        super.init()
        frc.delegate = self
    }

    override var sections: [FetchedSection]? {
        return frc.sections?.map { section in
            return FetchedSection(name: section.name, numberOfObjects: section.numberOfObjects)
        }
    }

    override var fetchedObjects: [ResultType]? {
        return frc.fetchedObjects as? [ResultType]
    }

    override func performFetch() {
        do {
            try frc.performFetch()
        } catch {
            assertionFailure("\(#function) An error occurred performing fetch: \(error.localizedDescription)")
        }
    }

    override func object(at indexPath: IndexPath) -> ResultType? {
        return frc.object(at: indexPath) as? ResultType
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent(self)
    }
}
