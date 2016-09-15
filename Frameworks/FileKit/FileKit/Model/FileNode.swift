//
//  FileNode.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 7/24/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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
