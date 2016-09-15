//
//  FileUpload+Collections.swift
//  FileKit
//
//  Created by Egan Anderson on 6/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoPersistent

extension FileUpload {
    public static func contextIDPredicate(contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    public static func folderIDPredicate(folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }
    
    public static func rootFolderPredicate(isInRootFolder: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "isInRootFolder", isInRootFolder)
    }
    
    public static func predicate(contextID: ContextID, folderID: String?) -> NSPredicate {
        let contextID = contextIDPredicate(contextID)
        let folder = folderIDPredicate(folderID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, folder])
    }
}


extension FileUpload {
    public static func fetchCollection(session: Session, contextID: ContextID, folderID: String?) throws -> FetchedCollection<FileUpload> {
        let context = try session.filesManagedObjectContext()
        let predicate = FileUpload.predicate(contextID, folderID: folderID)
        let frc = FileUpload.fetchedResults(predicate, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<FileUpload>(frc: frc)
    }
}