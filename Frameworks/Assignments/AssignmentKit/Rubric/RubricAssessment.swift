//
//  RubricAssessment.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public final class RubricAssessment: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber?
    
    @NSManaged internal (set) public var submission: Submission
}

import SoPersistent
import Marshal
import SoLazy

extension RubricAssessment {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let assessmentID: String = try json.stringID("id")
        let submissionID: String = try json.stringID("submissionID")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", assessmentID, "submission.id", submissionID)
    }
    
    public func updateValues(assessmentID: String, submission: Submission, json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = assessmentID
        comments = try json <| "comments"
        points = try json <| "points"
        
        self.submission = submission
    }
}

