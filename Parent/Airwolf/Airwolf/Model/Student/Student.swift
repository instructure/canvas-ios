
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
import SoPersistent
import Marshal
import SoLazy

public final class Student: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var parentID: String
    @NSManaged private (set) public var name: String
    @NSManaged private (set) public var shortName: String
    @NSManaged private (set) public var sortableName: String
    @NSManaged private (set) public var avatarURL: NSURL?
    @NSManaged private (set) public var domain: NSURL
}

extension Student: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("student_id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("student_id")
        parentID        = try json.stringID("parent_id")
        name            = try json <| "student_name"
        shortName       = try json <| "short_name" ?? name
        sortableName    = try json <| "sortable_name" ?? name
        avatarURL       = try json <| "avatar_url"
        domain          = try json <| "student_domain"
    }
}