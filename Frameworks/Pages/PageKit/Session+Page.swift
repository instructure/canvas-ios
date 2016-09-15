//
//  Session+Page.swift
//  Pages
//
//  Created by Joseph Davison on 5/13/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let pageKitModelName = "PageKit"
let pageKitStoreName = "PageKit"

extension Session {
    func pagesManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: pageKitModelName, inBundle: NSBundle(forClass: Page.self))?.mutableCopy() as? NSManagedObjectModel else {
            ❨╯°□°❩╯⌢"Could not load Page model in Session+Page extension"
        }
        
        let storeID = StoreID(storeName: pageKitStoreName, model: model, localizedErrorDescription: NSLocalizedString("There was a problem loading the Pages database file.", comment: "Page list fails"))
        
        return try managedObjectContext(storeID)
    }
}
