//
//  Session+AssignmentKit.swift
//  Assignments
//
//  Created by Derrick Hathaway on 1/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import FileKit
import SoLazy

let assignmentKitModelName = "AssignmentKit"
let assignmentKitSubdomain = "AssignmentKit"
let assignmentKitFailedToLoadErrorCode = 10001
let assignmentKitFailedToLoadErrorDescription = "Failed to load \(assignmentKitModelName) NSManagedObjectModel"
let assignmentKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the AssignmentKit database file.", comment: "AssignmentKit database load failure message")

extension Session {
    public func assignmentsManagedObjectContext(scope: String? = nil) throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: assignmentKitModelName, inBundle: NSBundle(forClass: Assignment.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: assignmentKitSubdomain, code: assignmentKitFailedToLoadErrorCode, title: assignmentKitFailedToLoadErrorDescription, description: assignmentKitDBFailedToLoadErrorDescription)
        }
        let withFiles = model.loadingFileEntity()

        let storeName = scope == nil ? assignmentKitModelName : "\(assignmentKitModelName)_\(scope!)"
        let storeID = StoreID(storeName: storeName, model: withFiles, localizedErrorDescription: assignmentKitDBFailedToLoadErrorDescription)
        
        return try managedObjectContext(storeID)
    }
}
