//
//  File+Factory.swift
//  FileKit
//
//  Created by Egan Anderson on 5/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import CoreData
import TooLegit

extension File {
    static func build(context: NSManagedObjectContext, contextID: ContextID = ContextID(id: "1", context: .User), id: String = "1", name: String = "New File") -> File {
        let file = File.create(inContext: context)
        file.contextID = contextID
        file.id = id
        file.name = name
        return file
    }
}