//
//  Session+Alert.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import CoreData
import SoPersistent
import SoLazy

let alertKitModelName = "ObserverAlertKit"
let alertKitStoreName = "ObserverAlertKit"
let alertKitSubdomain = "ObserverAlertKit"
let alertKitFailedToLoadErrorCode = 10001
let alertKitFailedToLoadErrorDescription = "Failed to load \(alertKitModelName) NSManagedObjectModel"
let alertKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AlertKit database file.", comment: "AlertKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current alert context
// ---------------------------------------------
extension Session {
    func alertsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: alertKitModelName, inBundle: NSBundle(forClass: Alert.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: alertKitSubdomain, code: alertKitFailedToLoadErrorCode, title: alertKitFailedToLoadErrorDescription, description: alertKitFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: alertKitStoreName, model: model,
                              localizedErrorDescription: alertKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}