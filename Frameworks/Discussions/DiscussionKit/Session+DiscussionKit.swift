//
//  Session+DiscussionKit.swift
//  Discussions
//
//  Created by Ben Kraus on 3/24/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy
import FileKit

let discussionKitModelName = "DiscussionKit"
let discussionKitSubdomain = "DiscussionKit"
let discussionKitFailedToLoadErrorCode = 10001
let discussionKitFailedToLoadErrorDescription = "Failed to load \(discussionKitModelName) NSManagedObjectModel"
let discussionKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the DiscussionKit database file.", comment: "DiscussionKit Database Load Failure Message")

extension Session {
    public func discussionsManagedObjectContext(scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: discussionKitModelName, inBundle: NSBundle(forClass: DiscussionTopic.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: discussionKitSubdomain, code: discussionKitFailedToLoadErrorCode, title: discussionKitFailedToLoadErrorDescription, description: discussionKitFailedToLoadErrorDescription)
        }
        let withFiles = model.loadingFileEntity()

        let storeName = scope == nil ? discussionKitModelName : "\(discussionKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: withFiles,
                              localizedErrorDescription: discussionKitDBFailedToLoadErrorDescription)

        return try managedObjectContext(storeID)
    }
}

