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
    
    

import Foundation

import Marshal

import CoreData


public final class MediaComment: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var contentType: String
    @NSManaged var url: URL?
    
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
    
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json <| "media_id"
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        try id = json <| "media_id"
        try name = json <| "display_name"
        try contentType = json <| "contentType"
        try kind = json <| "media_type"
        try url = json <| "url"
    }
}
