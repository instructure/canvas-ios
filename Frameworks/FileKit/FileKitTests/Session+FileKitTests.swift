//
//  Session+FileKitTests.swift
//  FileKit
//
//  Created by Nathan Armstrong on 5/17/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import TooLegit
import SoPersistent
import SoLazy
import CoreData

extension Session {
    func fileKitTestsManagedObjectContext() throws -> NSManagedObjectContext {
        guard let model = NSManagedObjectModel(named: "FileKitTests", inBundle: NSBundle(forClass: FileUploadTests.self))?.mutableCopy() as? NSManagedObjectModel else { ❨╯°□°❩╯⌢"problems?" }
        let withFiles = model.loadingFileEntity()

        let storeID = StoreID(storeName: "FileKitTests", model: withFiles,
            localizedErrorDescription: NSLocalizedString("There was a problem loading the FileKitTests database file.", comment: "FileKit Tests database fails"))
        
        return try managedObjectContext(storeID)
    }
}
