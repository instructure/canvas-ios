//
//  File.swift
//  FileKit
//
//  Created by Egan Anderson on 5/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoLazy
import CoreData
import ReactiveCocoa
import AVFoundation

public final class File: FileNode {
    @NSManaged public var contentType: String?
    @NSManaged public var size: Int64 //in bytes
    @NSManaged public var url: NSURL
    @NSManaged public var thumbnailURL: NSURL?
    
    override public var icon: UIImage {
        iconName = "icon_document"
        if lockedForUser {
            iconName = "icon_locked"
        } else if contentType?.rangeOfString("image") != nil {
            iconName = "icon_image"
        } else if contentType?.rangeOfString("video") != nil {
            iconName = "icon_video_clip"
        } else if contentType?.rangeOfString("text") != nil {
            iconName = "icon_page"
        } else if contentType?.rangeOfString("application") != nil {
            if contentType?.rangeOfString("pdf") != nil {
                iconName = "icon_pdf"
            } else if name.rangeOfString(".doc") != nil && contentType?.rangeOfString(".doc") != nil {
                iconName = "icon_page"
            }
        }
        let bundle = NSBundle(forClass: File.self)
        return UIImage(named: iconName, inBundle: bundle, compatibleWithTraitCollection: nil)!
    }
    
    override public func deleteFileNode(session: Session, shouldForce: Bool) throws -> SignalProducer<Void, NSError> {
        let context = try session.filesManagedObjectContext()
        
        let network: SignalProducer<JSONObject, NSError> = attemptProducer {
            return try File.deleteFile(session, fileID: self.id)
        }.flatten(.Merge)
        
        let local: SignalProducer<Void, NSError> = attemptProducer {
            context.deleteObject(self)
            try context.save()
        }
        .startOn(ManagedObjectContextScheduler(context: context))
        return network.map({ _ in () }).concat(local)
    }
    
    public static func uploadFile(inSession session: Session, newUploadFiles: [NewUploadFile], folderID: String?, contextID: ContextID, backgroundSession: Session) throws {
        let context = try session.filesManagedObjectContext()
        let path: String
        if let folderID = folderID {
            path = "/api/v1/folders/\(folderID)/files"
        } else {
            path = contextID.apiPath/"files"
        }
        for newUploadFile in newUploadFiles {
            let name = newUploadFile.name
            let contentType = newUploadFile.contentType
            newUploadFile.extract { data in
                if let data = data {
                    let fileUpload = FileUpload.createInContext(context)
                    fileUpload.prepare(backgroundSession.sessionID, path: path, data: data, name: name, contentType: contentType, parentFolderID: folderID, contextID: contextID)
                    fileUpload.begin(inSession: backgroundSession, inContext: context)
                }
            }
        }
    }
    
    public static func uploadIdentifier (folderID: String?) -> String {
        if let folderID = folderID {
            return "file-upload-\(folderID)"
        } else {
            return "file-upload-root"
        }
    }
}

import SoPersistent
import Marshal

extension File: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        isFolder = false
        id = try json.stringID("id")
        try name = json <| "display_name"
        try hiddenForUser = json <| "hidden_for_user" ?? false
        try contentType = json <| "content-type"
        try thumbnailURL = json <| "thumbnail_url"
        try url = json <| "url"
        try size = json <| "size"
        
        try updateLockStatus(json)
    }
}
