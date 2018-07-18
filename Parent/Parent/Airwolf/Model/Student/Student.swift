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
import CanvasCore

public final class Student: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var parentID: String
    @NSManaged fileprivate (set) public var name: String
    @NSManaged fileprivate (set) public var shortName: String
    @NSManaged fileprivate (set) public var sortableName: String
    @NSManaged fileprivate (set) public var avatarURL: URL?
    @NSManaged fileprivate (set) public var domain: URL
}

extension Student: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("student_id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("student_id")
        parentID        = try json.stringID("parent_id")
        name            = try json <| "student_name"
        shortName       = (try json <| "short_name") ?? name
        sortableName    = (try json <| "sortable_name") ?? name
        avatarURL       = try json <| "avatar_url"
        domain          = try json <| "student_domain"
    }
}
