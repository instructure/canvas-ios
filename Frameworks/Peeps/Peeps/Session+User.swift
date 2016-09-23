//
//  Session+User.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit
import CoreData
import SoPersistent
import SoLazy

let peepKitModelName = "Peeps"
let peepKitStoreName = "ObservedUsers"
let peepKitSubdomain = "PeepKit"
let peepKitFailedToLoadErrorCode = 10001
let peepKitFailedToLoadErrorDescription = "Failed to load \(peepKitModelName) NSManagedObjectModel"
let peepKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the PeepKit database file.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Peeps")!, value: "", comment: "PeepKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user observees
// ---------------------------------------------
extension Session {
    func observeesManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "Peeps", inBundle: NSBundle(forClass: User.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: peepKitSubdomain, code: peepKitFailedToLoadErrorCode, title: peepKitFailedToLoadErrorDescription, description: peepKitFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: peepKitStoreName, model: model,
            localizedErrorDescription: peepKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}