//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation
import CoreData
@testable import Core

public var singleSharedTestDatabase: NSPersistentContainer = resetSingleSharedTestDatabase()

public func resetSingleSharedTestDatabase() -> NSPersistentContainer {
    let bundle = Bundle.core
    let modelURL = bundle.url(forResource: "Database", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    FileUploadTargetTransformer.register()
    UIColorTransformer.register()
    let container = TestDatabase(name: "Database", managedObjectModel: model)
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType
    description.shouldAddStoreAsynchronously = false

    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { (description, error) in
        // Check if the data store is in memory
        precondition( description.type == NSInMemoryStoreType )

        // Check if creating container wrong
        if let error = error {
            fatalError("Create an in-memory coordinator failed \(error)")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    return container
}

class TestDatabase: NSPersistentContainer, @unchecked Sendable {
    override func newBackgroundContext() -> NSManagedObjectContext {
        // create a new view context to avoid recursive saves
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    override func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.performAndWait {
            block(self.viewContext)
        }
    }

    override func performWriteTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        self.viewContext.performAndWait {
            block(self.viewContext)
        }
    }
}
