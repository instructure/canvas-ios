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


import CoreData
import ReactiveSwift
import Marshal


open class FileNode: NSManagedObject, LockableModel {
    @NSManaged open var id: String
    @NSManaged open var name: String
    @NSManaged open var hiddenForUser: Bool
    @NSManaged open var isFolder: Bool
    @NSManaged open var rawContextID: String
    
    /// MARK: Locking
    @NSManaged open var lockedForUser: Bool
    @NSManaged open var lockExplanation: String?
    @NSManaged open var canView: Bool
    
    internal (set) open var contextID: ContextID {
        get {
            return ContextID(canvasContext: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }
    
    @NSManaged open var isInRootFolder: Bool
    @NSManaged open var parentFolderID: String?
    open var iconName: String!
    
    open var icon: UIImage {
        let iconName: String = "icon_document"
        let bundle = Bundle(for: File.self)
        return UIImage(named: iconName, in: bundle, compatibleWith: nil)!
    }
    
    open func deleteFileNode(_ session: Session, shouldForce: Bool) throws -> SignalProducer<Void, NSError> {
        fatalError("Subclass must override")
    }
}
