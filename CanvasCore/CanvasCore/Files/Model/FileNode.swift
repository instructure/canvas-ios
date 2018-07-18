//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
