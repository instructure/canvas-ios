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

public final class DueDateOverride: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var title: String
    @NSManaged fileprivate (set) public var due: Date
    
    @NSManaged var assignment: Assignment?
}



import Marshal

extension DueDateOverride: SynchronizedModel {
    
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id      = try json.stringID("id")
        title   = try json <| "title"
        due     = try json <| "due_at"
        
        let assignmentID: String = try json.stringID("assignment_id")
        let assignment: Assignment? = try context.findOne(withValue: assignmentID, forKey: "id")
        self.assignment = assignment
    }
}
