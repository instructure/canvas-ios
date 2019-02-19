//
// Copyright (C) 2018-present Instructure, Inc.
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
import Core

public var singleSharedTestDatabase: Persistence  = resetSingleSharedTestDatabase()

public func resetSingleSharedTestDatabase() -> Persistence {
    let bundle = Bundle.core
    let modelURL = bundle.url(forResource: "Database", withExtension: "momd")!
    let model = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(name: "Database", managedObjectModel: model)
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
