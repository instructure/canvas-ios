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

public final class RubricCriterion: NSManagedObject {
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var criterionDescription: String
    @NSManaged internal (set) public var longDescription: String?
    @NSManaged internal (set) public var points: NSNumber
    @NSManaged internal (set) public var position: NSNumber
    
    @NSManaged internal (set) public var ratings: Set<RubricCriterionRating>
}


import Marshal


extension RubricCriterion {
    
    public static func uniquePredicateForObject(_ assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id") ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "assignmentID", assignmentID)
    }
    
    public func updateValues(_ json: JSONObject, assignmentID: String, position: NSNumber, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        criterionDescription = try json <| "description"
        longDescription = try json <| "long_description"
        points = try json <| "points"
        
        self.assignmentID = assignmentID
        self.position = position
        
        if let criterionRatings: [JSONObject] = try json <| "ratings" {
            for rating in criterionRatings {
                if let rubricCriterionRating: RubricCriterionRating = try context.findOne(withPredicate: try RubricCriterionRating.uniquePredicateForObject(id, assignmentID: self.assignmentID, json: rating)) {
                    try rubricCriterionRating.updateValues(rating, assignmentID: self.assignmentID, inContext: context)
                
                    ratings.insert(rubricCriterionRating)
                } else {
                    let rubricCriterionRating = RubricCriterionRating(inContext: context)
                    try rubricCriterionRating.updateValues(rating, assignmentID: self.assignmentID, inContext: context)
                    
                    ratings.insert(rubricCriterionRating)
                }
            }
        }
    }
}
