//
//  Session+TodoKit.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let kitModelName = "TodoKit"
let kitSubdomain = "TodoKit"
let kitFailedToLoadErrorCode = 10001
let kitFailedToLoadErrorDescription = "Failed to load \(kitModelName) NSManagedObjectModel"
let kitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the \(kitModelName) database file.", comment: "CalendarKit Database Load Failure Message")

// ---------------------------------------------
// MARK: - Session for current user Calendar Events
// ---------------------------------------------
extension Session {
    func todosManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: kitModelName, inBundle: NSBundle(forClass: Todo.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: kitSubdomain, code: kitFailedToLoadErrorCode, title: kitFailedToLoadErrorDescription, description: kitDBFailedToLoadErrorDescription)
        }

        let storeID = StoreID(storeName: kitModelName, model: model,
            localizedErrorDescription: kitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}