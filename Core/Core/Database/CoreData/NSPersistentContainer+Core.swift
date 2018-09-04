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

public let coreDataStore = NSPersistentContainer.shared

extension NSPersistentContainer {
    public static var shared: NSPersistentContainer {
        let bundle = Bundle(identifier: "com.instructure.icanvas.Core")!
        guard let modelURL = bundle.url(forResource: "Database", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Model file not found")
        }

        let container = NSPersistentContainer(name: "Database", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }
}

extension NSPersistentContainer: DatabaseStore {
    public func perform(block: @escaping (DatabaseClient) -> Void) {
        DispatchQueue.main.async {
            block(self.viewContext)
        }
    }

    public func performBackgroundTask(block: @escaping (DatabaseClient) -> Void) {
        performBackgroundTask { (context: NSManagedObjectContext) in
            block(context)
        }
    }

    public var mainClient: DatabaseClient {
        return viewContext
    }

    public func clearAllRecords() throws {
        do {
            try persistentStoreCoordinator.managedObjectModel.entities.forEach { (entity) in
                if let name = entity.name {
                    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                    let request = NSBatchDeleteRequest(fetchRequest: fetch)
                    try viewContext.execute(request)
                }
            }

            try viewContext.save()
        } catch {
            throw error
        }
    }
}
