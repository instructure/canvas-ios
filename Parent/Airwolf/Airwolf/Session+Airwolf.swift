//
//  Session+Airwolf.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy

extension Session {
    public func airwolfManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "Airwolf", inBundle: NSBundle(forClass: Student.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: "Airwolf", description: "Failed to load Airwolf NSManagedObjectModel")
        }

        let storeID = StoreID(storeName: "Airwolf", model: model, localizedErrorDescription: NSLocalizedString("There was a problem loading the database.", comment: "Airwolf database error message"))

        return try managedObjectContext(storeID)
    }
}