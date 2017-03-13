//
// Copyright (C) 2016-present Instructure, Inc.
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
import ReactiveSwift
import Result

private let container = NSPersistentContainer(name: "Bagels")
private let mainProperty = MutableProperty<NSManagedObjectContext?>(nil)

extension NSManagedObjectContext {
    static func loadMain() {
        let storeDesc = NSPersistentStoreDescription(url: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Bagels.sqlite", isDirectory: false))
        storeDesc.shouldAddStoreAsynchronously = true
        storeDesc.shouldMigrateStoreAutomatically = true
        storeDesc.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [storeDesc]
        container.loadPersistentStores { (_, error) in
            if let e = error { fatalError(e.localizedDescription) }
            let main = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
            main.persistentStoreCoordinator = container.persistentStoreCoordinator

            mainProperty.value = main
        }
    }
    
    static var mainContext: SignalProducer<NSManagedObjectContext, NoError> {
        return mainProperty
            .producer
            .skipNil()
            .take(first: 1)
    }
}
