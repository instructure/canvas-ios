//
//  Session+SuchActivity.swift
//  SuchActivity
//
//  Created by Derrick Hathaway on 11/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import TooLegit
import SoPersistent

extension Session {
    var suchActivityManagedObjectContext: NSManagedObjectContext {
        let model = NSManagedObjectModel(named: "SuchActivity", inBundle: .suchActivity)!
        
        let storeID = StoreID(storeName: "SuchActivity", model: model, localizedErrorDescription: "Error loading SuchActivity database file")
        
        return try! managedObjectContext(storeID)
    }
}
