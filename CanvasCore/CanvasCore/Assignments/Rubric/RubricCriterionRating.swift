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

import Marshal

public final class RubricCriterionRating: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber
    @NSManaged internal (set) public var ratingDescription: String
}

extension RubricCriterionRating {
    public static func uniquePredicateForObject(_ criterionID: String, assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id : String = (try json <| "id") ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@ && %K.%K == %@", "id", id, "assignmentID", assignmentID, "criterion", "id", criterionID)
    }
    
    public func updateValues(_ json: JSONObject, assignmentID: String, inContext context: NSManagedObjectContext) throws {
            id = (try json <| "id") ?? ""
            points = try json <| "points"
            ratingDescription = try json <| "description"
            self.assignmentID = assignmentID
    }
}
