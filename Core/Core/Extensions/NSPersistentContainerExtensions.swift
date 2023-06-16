//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Combine
import CoreData

extension NSPersistentContainer {

    // MARK: - Public Static Interface

    public static let shared = create(appGroup: Bundle.main.appGroupID())

    public static func create(appGroup: String? = Bundle.main.appGroupID(),
                              session: LoginSession? = nil)
    -> NSPersistentContainer {
        let modelFileURL = Bundle.core.url(forResource: "Database", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelFileURL)!
        FileUploadTargetTransformer.register()
        let container = NSPersistentContainer(name: "Database", managedObjectModel: model)

        let url = URL.Directories.databaseURL(appGroup: appGroup, session: session)
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: url)
        ]

        container.loadPersistentStores { _, error in
            guard error == nil else {
                destroyAndReCreatePersistentStore(in: container)
                return
            }
            container.setUp()
        }
        return container
    }

    // MARK: - Public Instance Methods

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
            for description in persistentStoreDescriptions {
                if let url = description.url {
                    try persistentStoreCoordinator.destroyPersistentStore(at: url,
                                                                          ofType: description.type,
                                                                          options: nil)
                }
            }
        } catch {
            // It's not the worst thing ever if we can't destroy the db
            // because it is scoped to the user
            print(error)
        }
    }

    @objc open func performWriteTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let context = writeContext ?? {
            let context = newBackgroundContext()
            context.automaticallyMergesChangesFromParent = true
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            writeContext = context
            return context
        }()
        context.perform { block(context) }
    }

    // MARK: - Private Methods

    private static func destroyAndReCreatePersistentStore(in container: NSPersistentContainer) {
        container.destroy() // ignore migration conflicts
        container.loadPersistentStores { _, error in
            guard error == nil else {
                destroyAndCreateInMemoryStore(in: container)
                return
            }
            container.setUp()
        }
    }

    private static func destroyAndCreateInMemoryStore(in container: NSPersistentContainer) {
        container.destroy() // ignore migration conflicts
        container.persistentStoreDescriptions = [
            NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        ]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError(error.localizedDescription)
            }
            container.setUp()
        }
    }

    private func setUp() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    private var writeContext: NSManagedObjectContext? {
        get { objc_getAssociatedObject(self, &writeContextKey) as? NSManagedObjectContext }
        set { objc_setAssociatedObject(self, &writeContextKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}

private var writeContextKey: UInt8 = 0
