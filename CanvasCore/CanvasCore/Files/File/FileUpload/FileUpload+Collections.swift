//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import UIKit



extension FileUpload {
    public static func contextIDPredicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    @objc public static func folderIDPredicate(_ folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }
    
    @objc public static func rootFolderPredicate(_ isInRootFolder: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "isInRootFolder", isInRootFolder as CVarArg)
    }
    
    public static func predicate(_ contextID: ContextID, folderID: String?) -> NSPredicate {
        let contextID = contextIDPredicate(contextID)
        let folder = folderIDPredicate(folderID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, folder])
    }

    @objc public static func predicate(batch: FileUploadBatch) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "batch", batch)
    }

    @objc public static func inProgressPredicate() -> NSPredicate {
        return NSPredicate(format: "%K != nil && %K == nil", "startedAt", "terminatedAt")
    }

    @objc public static func completedPredicate() -> NSPredicate {
        return NSPredicate(format: "%K != nil", "completedAt")
    }

    @objc public static func inProgressPredicate(batch: FileUploadBatch) -> NSPredicate {
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: [self.predicate(batch: batch), self.inProgressPredicate()])
    }

    @objc public static func completedPredicate(batch: FileUploadBatch) -> NSPredicate {
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: [self.predicate(batch: batch), self.completedPredicate()])
    }
}


extension FileUpload {
    public static func fetchCollection(_ session: Session, contextID: ContextID, folderID: String?) throws -> FetchedCollection<FileUpload> {
        let context = try session.filesManagedObjectContext()
        let predicate = FileUpload.predicate(contextID, folderID: folderID)
        return try FetchedCollection<FileUpload>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["name".ascending])
        )
    }

    public static func fetchCollection(_ session: Session, batch: FileUploadBatch) throws -> FetchedCollection<FileUpload> {
        let context = try session.filesManagedObjectContext()
        let predicate = FileUpload.predicate(batch: batch)
        return try FetchedCollection<FileUpload>(frc:
            context.fetchedResults(predicate, sortDescriptors: ["name".ascending])
        )
    }
}
