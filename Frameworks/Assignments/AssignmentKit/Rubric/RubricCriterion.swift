//
//  RubricCriterion.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

import SoPersistent
import Marshal
import SoLazy

extension RubricCriterion: Model {
    
    public static func uniquePredicateForObject(assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id") ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "assignmentID", assignmentID)
    }
    
    public func updateValues(json: JSONObject, assignmentID: String, position: NSNumber, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        criterionDescription = try json <| "description"
        longDescription = try json <| "long_description"
        points = try json <| "points"
        
        self.assignmentID = assignmentID
        self.position = position
        
        if let criterionRatings: [JSONObject] = try json <| "ratings" ?? [] {
            for rating in criterionRatings {
                if let rubricCriterionRating = try RubricCriterionRating.findOne(try RubricCriterionRating.uniquePredicateForObject(id, assignmentID: self.assignmentID, json: rating), inContext: context) {
                    try rubricCriterionRating.updateValues(rating, assignmentID: self.assignmentID, inContext: context)
                
                    ratings.insert(rubricCriterionRating)
                } else {
                    let rubricCriterionRating = RubricCriterionRating.create(inContext: context)
                    try rubricCriterionRating.updateValues(rating, assignmentID: self.assignmentID, inContext: context)
                    
                    ratings.insert(rubricCriterionRating)
                }
            }
        }
    }
}
