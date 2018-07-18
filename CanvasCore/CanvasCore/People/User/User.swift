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
import CoreData

import Marshal


public final class User: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var loginID: String?
    @NSManaged fileprivate (set) public var name: String
    @NSManaged fileprivate (set) public var sortableName: String
    @NSManaged fileprivate (set) public var email: String?
    @NSManaged fileprivate (set) public var avatarURL: URL?
    @NSManaged fileprivate (set) public var obverveeID: String?
}

extension User: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("id")
        name            = try json <| "name"
        loginID         = try json <| "login_id"
        sortableName    = try json <| "sortable_name"
        email           = try json <| "primary_email"
        
        if let avatarURLString: String = try json <| "avatar_url" {
            avatarURL   = URL(string: avatarURLString)
        }
    }
}
