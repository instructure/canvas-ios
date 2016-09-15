//
//  MediaComment.swift
//  iCanvas
//
//  Created by Derrick Hathaway on 7/31/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

import Foundation
import SoLazy
import Marshal
import SoPersistent
import CoreData


public final class MediaComment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var contentType: String
    @NSManaged var url: NSURL?
    
    public enum Kind: String {
        case Video = "video"
        case Audio = "audio"
    }
    @NSManaged var rawKind: String
    public var kind: Kind {
        get {
            return Kind(rawValue: rawKind) ?? .Video
        } set {
            rawKind = newValue.rawValue
        }
    }

}

extension MediaComment: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json <| "media_id"
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id = json <| "media_id"
        try name = json <| "display_name"
        try contentType = json <| "contentType"
        try kind = json <| "media_type"
        try url = json <| "url"
    }
}
