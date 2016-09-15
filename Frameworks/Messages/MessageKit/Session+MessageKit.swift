//
//  Session+MessageKit.swift
//  Messages
//
//  Created by Nathan Armstrong on 6/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoPersistent
import CoreData

let messageKitModelName = "MessageKit"
let messageKitSubdomain = "MessageKit"
let messageKitFailedToLoadErrorCode = 10001
let messageKitFailedToLoadErrorDescription = "Failed to load \(messageKitModelName) NSManagedObjectModel"
let messageKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the MessageKit database file.", comment: "MessageKit database load failure message")

extension Session {
    public func messagesManagedObjectContext() throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel(named: messageKitModelName, inBundle: NSBundle(forClass: Conversation.self))!.mutableCopy() as! NSManagedObjectModel
        let storeID = StoreID(storeName: messageKitModelName, model: model, localizedErrorDescription: messageKitDBFailedToLoadErrorDescription)
        return try managedObjectContext(storeID)
    }
}
