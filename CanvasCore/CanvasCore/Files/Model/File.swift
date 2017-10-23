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
import AVFoundation

public final class File: FileNode {
    @NSManaged public var contentType: String?
    @NSManaged public var size: Int64 //in bytes
    @NSManaged public var url: URL
    @NSManaged public var thumbnailURL: URL?
    
    override public var icon: UIImage {
        iconName = "icon_document"
        if lockedForUser {
            iconName = "icon_locked"
        } else if contentType?.range(of: "image") != nil {
            iconName = "icon_image"
        } else if contentType?.range(of: "video") != nil {
            iconName = "icon_video_clip"
        } else if contentType?.range(of: "text") != nil {
            iconName = "icon_page"
        } else if contentType?.range(of: "application") != nil {
            if contentType?.range(of: "pdf") != nil {
                iconName = "icon_pdf"
            } else if name.range(of: ".doc") != nil && contentType?.range(of: ".doc") != nil {
                iconName = "icon_page"
            }
        }
        let bundle = Bundle(for: File.self)
        return UIImage(named: iconName, in: bundle, compatibleWith: nil)!
    }
    
    override public func deleteFileNode(_ session: Session, shouldForce: Bool) throws -> SignalProducer<Void, NSError> {
        let context = try session.filesManagedObjectContext()
        
        let network: SignalProducer<JSONObject, NSError> = attemptProducer {
            return try File.deleteFile(session, fileID: self.id)
        }.flatten(.merge)
        
        let local: SignalProducer<Void, NSError> = attemptProducer {
                context.delete(self)
                try context.save()
            }
            .start(on: ManagedObjectContextScheduler(context: context))
        return network.map({ _ in () }).concat(local)
    }
    
    public static func uploadIdentifier (_ folderID: String?) -> String {
        if let folderID = folderID {
            return "file-upload-\(folderID)"
        } else {
            return "file-upload-root"
        }
    }
}


import Marshal

extension File: SynchronizedModel {
    
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        isFolder = false
        id = try json.stringID("id")
        try name = json <| "display_name"
        try hiddenForUser = (json <| "hidden_for_user") ?? false
        try contentType = json <| "content-type"
        try thumbnailURL = json <| "thumbnail_url"
        try url = json <| "url"
        try size = json <| "size"
        
        try updateLockStatus(json)
    }
}
