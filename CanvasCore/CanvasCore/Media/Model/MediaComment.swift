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
