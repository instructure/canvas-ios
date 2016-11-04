
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

extension NSManagedObjectContext {

    public static func inMemoryTestContext(model: NSManagedObjectModel) -> NSManagedObjectContext {
        return testContext(model) { $0.addInMemoryTestStore() }
    }

    public static func errorProneContext(model: NSManagedObjectModel) -> NSManagedObjectContext {
        return testContext(model) { $0.addErrorProneStore() }
    }

    static func testContext(model: NSManagedObjectModel, addStore: NSPersistentStoreCoordinator -> ()) -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        addStore(coordinator)
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }
}

extension NSPersistentStoreCoordinator {

    func addInMemoryTestStore() {
        try! addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    }

    func addErrorProneStore() {
        NSPersistentStoreCoordinator.registerStoreClass(ErrorProneStore.self, forStoreType: ErrorProneStoreType)
        try! addPersistentStoreWithType(ErrorProneStoreType, configuration: nil, URL: nil, options: nil)
    }

}
