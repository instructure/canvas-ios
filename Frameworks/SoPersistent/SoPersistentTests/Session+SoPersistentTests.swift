//
//  Session+SoPersistentTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoPersistent
import SoLazy
import CoreData

extension Session {
    func soPersistentTestsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "DataModel", inBundle: NSBundle(forClass: Panda.self))?.mutableCopy() as? NSManagedObjectModel else { ❨╯°□°❩╯⌢"problems?" }

        let storeID = StoreID(storeName: "SoPersistentTests", model: model,
            localizedErrorDescription: NSLocalizedString("There was a problem loading the SoPersistentTests database file.", comment: "SoPersistent Tests database fails"))
        
        return try managedObjectContext(storeID)
    }
}
