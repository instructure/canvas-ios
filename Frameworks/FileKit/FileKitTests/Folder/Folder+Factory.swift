//
//  Folder+Factory.swift
//  FileKit
//
//  Created by Egan Anderson on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import CoreData
import TooLegit

extension Folder {
    static func build(context: NSManagedObjectContext, contextID: ContextID = ContextID(id: "1", context: .User), id: String = "1", name: String = "New Folder") -> Folder {
        let folder = Folder(inContext: context)
        folder.contextID = contextID
        folder.id = id
        folder.name = name
        return folder
    }
}
