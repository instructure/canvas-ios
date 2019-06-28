//
// Copyright (C) 2019-present Instructure, Inc.
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
    public static let shared = create(appGroup: Bundle.main.appGroupID())

    public static func create(appGroup: String? = Bundle.main.appGroupID(), session: KeychainEntry? = nil) -> NSPersistentContainer {
        let model = NSManagedObjectModel(contentsOf: Bundle.core.url(forResource: "Database", withExtension: "momd")!)!
        let container = NSPersistentContainer(name: "Database", managedObjectModel: model)

        if let url = databaseURL(for: appGroup, session: session) {
            container.persistentStoreDescriptions = [ NSPersistentStoreDescription(url: url) ]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
        return container
    }

    public static func databaseURL(for appGroup: String?, session: KeychainEntry?) -> URL? {
        var folder = URL.cachesDirectory

        if let appGroup = appGroup {
            guard let appGroupFolder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
                preconditionFailure("App Group does not exist")
            }
            folder = appGroupFolder
        }

        var fileName = "Database.sqlite"
        if let host = session?.baseURL.host, let userID = session?.userID {
            fileName = "Database-\(host)-\(userID).sqlite"
        }
        return folder.appendingPathComponent(fileName)
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

    public func destroy() {
        do {
            for url in persistentStoreCoordinator.persistentStores.compactMap({ $0.url }) {
                try persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            }
        } catch {
            // It's not the worst thing ever if we can't destroy the db
            // because it is scoped to the user
            print(error)
        }
    }
}
