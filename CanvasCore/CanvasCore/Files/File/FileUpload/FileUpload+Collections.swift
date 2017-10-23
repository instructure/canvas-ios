//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import UIKit



extension FileUpload {
    public static func contextIDPredicate(_ contextID: ContextID) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "rawContextID", contextID.canvasContextID)
    }
    
    public static func folderIDPredicate(_ folderID: String?) -> NSPredicate {
        if let folderID = folderID {
            return NSPredicate(format:"%K == %@", "parentFolderID", folderID)
        } else {
            return rootFolderPredicate(true)
        }
    }
    
    public static func rootFolderPredicate(_ isInRootFolder: Bool) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "isInRootFolder", isInRootFolder as CVarArg)
    }
    
    public static func predicate(_ contextID: ContextID, folderID: String?) -> NSPredicate {
        let contextID = contextIDPredicate(contextID)
        let folder = folderIDPredicate(folderID)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [contextID, folder])
    }

    public static func predicate(batch: FileUploadBatch) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "batch", batch)
    }

    public static func inProgressPredicate() -> NSPredicate {
        return NSPredicate(format: "%K != nil && %K == nil", "startedAt", "terminatedAt")
    }

    public static func completedPredicate() -> NSPredicate {
        return NSPredicate(format: "%K != nil", "completedAt")
    }

    public static func inProgressPredicate(batch: FileUploadBatch) -> NSPredicate {
        return NSCompoundPredicate.init(andPredicateWithSubpredicates: [self.predicate(batch: batch), self.inProgressPredicate()])
    }

    public static func completedPredicate(batch: FileUploadBatch) -> NSPredicate {
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
