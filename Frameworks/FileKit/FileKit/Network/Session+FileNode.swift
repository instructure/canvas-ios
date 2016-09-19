//
//  Session+File.swift
//  FileKit
//
//  Created by Egan Anderson on 5/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

let fileKitModelName = "FileKit"
let fileKitSubdomain = "FileKit"
let fileKitFailedToLoadErrorCode = 10001
let fileKitFailedToLoadErrorDescription = "Failed to load \(fileKitModelName) NSManagedObjectModel"
let fileKitDBFailedToLoadErrorDescription = NSLocalizedString("There was a problem loading the FileKit database file.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.FileKit")!, value: "", comment: "FileKit Database Load Failure Message")

extension Session {
    func filesManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: fileKitModelName, inBundle: NSBundle(forClass: FileNode.self))?.mutableCopy() as? NSManagedObjectModel else {
            throw NSError(subdomain: fileKitSubdomain, code: fileKitFailedToLoadErrorCode, title: fileKitFailedToLoadErrorDescription, description: fileKitFailedToLoadErrorDescription)
        }
        
        let storeID = StoreID(storeName: fileKitModelName, model: model,
                              localizedErrorDescription: fileKitDBFailedToLoadErrorDescription)
        
        return try managedObjectContext(storeID)
    }
}
