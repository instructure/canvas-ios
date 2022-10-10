//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

#if DEBUG

import Foundation
import CoreData

private var singleSharedPreviewDatabase: NSPersistentContainer  = resetSingleSharedPreviewDatabase()
private func resetSingleSharedPreviewDatabase() -> NSPersistentContainer {
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

public class PreviewEnvironment: AppEnvironment {
    override public init() {
        super.init()
        self.database = singleSharedPreviewDatabase
        self.globalDatabase = singleSharedPreviewDatabase
    }
}

public class PreviewStore<U: APIUseCase>: Store<U> {
    required public init(env: AppEnvironment = PreviewEnvironment(), useCase: U, contents: U.Response) {
        super.init(env: env, context: singleSharedPreviewDatabase.viewContext, useCase: useCase) { }
        useCase.write(response: contents, urlResponse: nil, to: singleSharedPreviewDatabase.viewContext)
    }
}
#endif
