//
//  Rubric.swift
//  Assignments
//
//  Created by Nathan Lambson on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public final class Rubric: NSManagedObject {
    
    //These all belong to the Rubric Settings object returned with the Rubric and the assignment
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var freeFormCriterionComments: Bool
    @NSManaged internal (set) public var pointsPossible: NSNumber
    
    @NSManaged internal (set) public var assignment: Assignment
    @NSManaged internal (set) public var currentSubmission: Submission?
    @NSManaged internal (set) public var courseID: String?
    @NSManaged internal (set) public var rubricCriterions: Set<RubricCriterion>
}

import SoPersistent
import Marshal
import SoLazy

extension Rubric {
    public static func uniquePredicateForObject(assignmentID: String) throws -> NSPredicate {
        let assignmentID: String = assignmentID
        return NSPredicate(format: "%K == %@", "assignmentID", assignmentID)
    }
    
    public func updateValues(rubricCriterionsJSON: [JSONObject], rubricSettingsJSON: JSONObject, assignmentID: String, inContext context: NSManagedObjectContext) throws {
        self.assignmentID = assignmentID
        title = try rubricSettingsJSON <| "title"
        freeFormCriterionComments = try rubricSettingsJSON  <| ("free_form_criterion_comments") ?? false
        pointsPossible = try rubricSettingsJSON <| "points_possible"

        for (index,criterion) in rubricCriterionsJSON.enumerate() {
            if let rubricCriterion: RubricCriterion = try context.findOne(withPredicate: try RubricCriterion.uniquePredicateForObject(self.assignmentID, json:criterion)) {
                try rubricCriterion.updateValues(criterion, assignmentID: assignmentID, position:index, inContext: context)
            
                rubricCriterions.insert(rubricCriterion)
            } else {
                let rubricCriterion = RubricCriterion(inContext: context)
                try rubricCriterion.updateValues(criterion, assignmentID: assignmentID, position:index, inContext: context)
                
                rubricCriterions.insert(rubricCriterion)
            }
        }
    }
    
    
}
