
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
import CoreData

public final class DueDateOverride: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var title: String
    @NSManaged private (set) public var due: NSDate
    
    @NSManaged var assignment: Assignment?
}


import SoPersistent
import Marshal

extension DueDateOverride: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id      = try json.stringID("id")
        title   = try json <| "title"
        due     = try json <| "due_at"
        
        let assignmentID: String = try json.stringID("assignment_id")
        let assignment: Assignment? = try context.findOne(withValue: assignmentID, forKey: "id")
        self.assignment = assignment
    }
}