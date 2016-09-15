//
//  Session+SoEdventurous.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy

private let modelName = "SoEdventurous"
private let dbFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the SoEdventurous database file.", comment: "SoEdventurous database load failure message")

extension Session {
    public func soEdventurousManagedObjectContext() throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: modelName, inBundle: NSBundle(forClass: Module.self))?.mutableCopy() as! NSManagedObjectModel
        let storeID = StoreID(storeName: modelName, model: model, localizedErrorDescription: dbFailedToLoadErrorDescription)
        return try managedObjectContext(storeID)
    }
}
