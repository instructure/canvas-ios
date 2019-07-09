//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
    
    @objc public static func uniquePredicateForObject(_ assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id") ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "assignmentID", assignmentID)
    }
    
    @objc public func updateValues(_ json: JSONObject, assignmentID: String, position: NSNumber, inContext context: NSManagedObjectContext) throws {
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
