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


import CoreData
import ReactiveSwift
import AVFoundation

public final class File: FileNode {
    @NSManaged public var contentType: String?
    @NSManaged public var size: Int64 //in bytes
    @NSManaged public var url: URL?
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
    
    @objc public static func uploadIdentifier (_ folderID: String?) -> String {
        if let folderID = folderID {
            return "file-upload-\(folderID)"
        } else {
            return "file-upload-root"
        }
    }
}


import Marshal

extension File: SynchronizedModel {
    
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
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
