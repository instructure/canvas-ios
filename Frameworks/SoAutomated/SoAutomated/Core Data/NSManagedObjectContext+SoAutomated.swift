//
//  NSManagedObjectContext+SoAutomated.swift
//  SoAutomated
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 instructure. All rights reserved.
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
