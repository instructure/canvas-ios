//
//  RubricCriterionRating.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import Marshal

public final class RubricCriterionRating: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber
    @NSManaged internal (set) public var ratingDescription: String
}

extension RubricCriterionRating: Model {
    public static func uniquePredicateForObject(criterionID: String, assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id : String = try json <| "id" ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@ && %K.%K == %@", "id", id, "assignmentID", assignmentID, "criterion", "id", criterionID)
    }
    
    public func updateValues(json: JSONObject, assignmentID: String, inContext context: NSManagedObjectContext) throws {
            id = try json <| "id" ?? ""
            points = try json <| "points"
            ratingDescription = try json <| "description"
            self.assignmentID = assignmentID
    }
}