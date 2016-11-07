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
import SoLazy
import CoreData
import ReactiveCocoa
import Marshal
import SoPersistent

public class FileNode: NSManagedObject, LockableModel {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var hiddenForUser: Bool
    @NSManaged public var isFolder: Bool
    @NSManaged public var rawContextID: String
    
    /// MARK: Locking
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var canView: Bool
    
    internal (set) public var contextID: ContextID {
        get {
            return ContextID(canvasContext: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }
    
    @NSManaged public var isInRootFolder: Bool
    @NSManaged public var parentFolderID: String?
    public var iconName: String!
    
    public var icon: UIImage {
        let iconName: String = "icon_document"
        let bundle = NSBundle(forClass: File.self)
        return UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }
    
    public func deleteFileNode(session: Session, shouldForce: Bool) throws -> SignalProducer<Void, NSError> {
        fatalError("Subclass must override")
    }
}
