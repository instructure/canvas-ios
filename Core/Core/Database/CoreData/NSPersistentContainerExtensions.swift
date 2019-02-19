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

extension NSPersistentContainer {
    public static func create(appGroup: String? = Bundle.main.appGroupID(), session: KeychainEntry? = nil) -> NSPersistentContainer {
        let model = NSManagedObjectModel(contentsOf: Bundle.core.url(forResource: "Database", withExtension: "momd")!)!
        let container = NSPersistentContainer(name: "Database", managedObjectModel: model)

        // If we are using this in the context of an shared AppGroup, make sure the name is correct
        let isUITest = ProcessInfo.isUITest
        // VTS: The code block below breaks Firebase Test Lab.
        if !isUITest, let url = databaseURL(for: appGroup, session: session) {
            container.persistentStoreDescriptions = [ NSPersistentStoreDescription(url: url) ]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        return container
    }

    public static func destroy(appGroup: String? = Bundle.main.appGroupID(), session: KeychainEntry? = nil) throws {
        guard let url = databaseURL(for: appGroup, session: session) else { return }
        try FileManager.default.removeItem(at: url)
    }

    public static func databaseURL(for appGroup: String?, session: KeychainEntry?) -> URL? {
        guard let appGroup = appGroup, let folder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else { return nil }
        var fileName = "Database.sqlite"
        if let host = session?.baseURL.host, let userID = session?.userID {
            fileName = "Database-\(host)-\(userID).sqlite"
        }
        return folder.appendingPathComponent(fileName)
    }
}

extension NSPersistentContainer: Persistence {
    public func perform(block: @escaping PersistenceBlockHandler) {
        DispatchQueue.main.async {
            block(self.viewContext)
        }
    }

    public func performBackgroundTask(block: @escaping PersistenceBlockHandler) {
        performBackgroundTask { (context: NSManagedObjectContext) in
            block(context)
        }
    }

    public var mainClient: PersistenceClient {
        return viewContext
    }

    public func clearAllRecords() throws {
        try persistentStoreCoordinator.managedObjectModel.entities.forEach { (entity) in
            if let name = entity.name {
                let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let request = NSBatchDeleteRequest(fetchRequest: fetch)
                try viewContext.execute(request)
            }
        }
        try viewContext.save()
    }

    public func fetchedResultsController<T>(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String?) -> FetchedResultsController<T> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return CoreDataFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: sectionNameKeyPath)
    }
}
