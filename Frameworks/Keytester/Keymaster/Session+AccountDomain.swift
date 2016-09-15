//
//  Session+AccountDomain.swift
//  Keytester
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let accountDomainModelName = "Keymaster"
let accountDomainSubdomain = "Keymaster"
let accountDomainFailedToLoadErrorCode = 10001
let accountDomainFailedToLoadErrorDescription = "Failed to load \(accountDomainModelName) NSManagedObjectModel"
let accountDomainDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AccountDomain database file.", comment: "AccountDomain Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user Calendar Events
// ---------------------------------------------
extension Session {
    func accountDomainsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: accountDomainModelName, inBundle: NSBundle(forClass: AccountDomain.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: accountDomainSubdomain, code: accountDomainFailedToLoadErrorCode, title: accountDomainFailedToLoadErrorDescription, description: accountDomainFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: accountDomainModelName, model: model,
            localizedErrorDescription: accountDomainDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}