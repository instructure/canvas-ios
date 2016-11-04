
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