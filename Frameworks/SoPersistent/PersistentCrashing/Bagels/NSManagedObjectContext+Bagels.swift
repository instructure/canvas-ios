//
//  NSManagedObjectContext+Bagels.swift
//  EverythingBagel
//
//  Created by Derrick Hathaway on 12/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
