//
//  FileUploadBatch.swift
//  FileKit
//
//  Created by Nathan Armstrong on 1/16/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import CoreData
import TooLegit

final public class FileUploadBatch: NSManagedObject {
    @NSManaged open internal(set) var primitiveFileTypes: String
    open internal(set) var fileTypes: [String] {
        get {
            return primitiveFileTypes.components(separatedBy: ",")
        }
        set {
            primitiveFileTypes = newValue.joined(separator: ",")
        }
    }

    @NSManaged open internal(set) var apiPath: String

    @NSManaged open internal(set) var fileUploads: Set<FileUpload>


    public convenience init(session: Session, fileTypes: [String], apiPath: String) {
        let context = try! session.filesManagedObjectContext()
        self.init(inContext: context)

        self.fileTypes = fileTypes
        self.apiPath = apiPath
    }
}
