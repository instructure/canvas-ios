
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

public final class Folder: FileNode {
    @NSManaged public var foldersUrl: NSURL
    @NSManaged public var filesUrl: NSURL
    @NSManaged public var filesCount: Int32
    @NSManaged public var foldersCount: Int32
    override public var icon: UIImage {
        iconName = "icon_folder_fill"
        if lockedForUser {
            iconName = "icon_locked_fill"
        }
        let bundle = NSBundle(forClass: File.self)
        return UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }
    
    override public func deleteFileNode(session: Session, shouldForce: Bool) throws -> SignalProducer<Void, NSError> {
        let context = try session.filesManagedObjectContext()
        
       let network: SignalProducer<JSONObject, NSError> = attemptProducer {
            return try Folder.deleteFolder(session, folderID: self.id, shouldForce: shouldForce)
        }.flatten(.Merge)
        
        let local = attemptProducer {
            context.deleteObject(self)
            try context.save()
        }
        .startOn(ManagedObjectContextScheduler(context: context))
       
        return network.map({ _ in () }).concat(local)
    }
    
    public class func create(inContext context: NSManagedObjectContext, contextID: ContextID) -> Folder {
        let folder = Folder(inContext: context)
        folder.contextID = contextID
        return folder
    }

    public class func newFolder(session: Session, contextID: ContextID, folderID: String?, name: String) -> SignalProducer<Void, NSError> {
        let local: JSONObject -> SignalProducer<Void, NSError> = { json in
            attemptProducer {
                let context = try session.filesManagedObjectContext()
                let folder = Folder.create(inContext: context, contextID: contextID)
                try folder.updateValues(json, inContext: context)
                folder.contextID = contextID
                folder.isInRootFolder = folderID == nil
                try context.save()
            }
        }
        
        if let folderID = folderID {
            let network: SignalProducer<JSONObject, NSError> = attemptProducer {
                return try Folder.addFolder(session, contextID: contextID, folderID: folderID, name: name)
            }.flatten(.Merge)
            
            
            return network.flatMap(.Concat, transform: local)

        } else {
            let folderID: SignalProducer<String,  NSError> = FileNode.getRootFolderID(session, contextID: contextID)!
            let network: String -> SignalProducer<JSONObject, NSError> = { folderID in
                attemptProducer {
                    return try Folder.addFolder(session, contextID: contextID, folderID: folderID, name: name)
                }.flatten(.Merge)
            }
            
            return folderID.flatMap(.Concat, transform: network).flatMap(.Concat, transform: local)
        }
    }
}

import SoPersistent
import Marshal

extension Folder: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        isFolder = true
        id = try json.stringID("id")
        try name = json <| "name"
        try hiddenForUser = json <| "hidden_for_user" ?? false
        try foldersUrl = json <| "folders_url"
        try filesUrl = json <| "files_url"
        try filesCount = json <| "files_count"
        try foldersCount = json <| "folders_count"
        try updateLockStatus(json)
        if let parentFolder: String = try json.stringID("parent_folder_id") {
            parentFolderID = parentFolder
        }
    }
}
