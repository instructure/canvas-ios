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


import Marshal


extension Rubric {
    public static func uniquePredicateForObject(_ assignmentID: String) throws -> NSPredicate {
        let assignmentID: String = assignmentID
        return NSPredicate(format: "%K == %@", "assignmentID", assignmentID)
    }
    
    public func updateValues(_ rubricCriterionsJSON: [JSONObject], rubricSettingsJSON: JSONObject, assignmentID: String, inContext context: NSManagedObjectContext) throws {
        self.assignmentID = assignmentID
        title = try rubricSettingsJSON <| "title"
        freeFormCriterionComments = (try rubricSettingsJSON  <| "free_form_criterion_comments") ?? false
        pointsPossible = try rubricSettingsJSON <| "points_possible"

        for (index,criterion) in rubricCriterionsJSON.enumerated() {
            if let rubricCriterion: RubricCriterion = try context.findOne(withPredicate: try RubricCriterion.uniquePredicateForObject(self.assignmentID, json:criterion)) {
                try rubricCriterion.updateValues(criterion, assignmentID: assignmentID, position:NSNumber(value: index), inContext: context)
            
                rubricCriterions.insert(rubricCriterion)
            } else {
                let rubricCriterion = RubricCriterion(inContext: context)
                try rubricCriterion.updateValues(criterion, assignmentID: assignmentID, position:NSNumber(value: index), inContext: context)
                
                rubricCriterions.insert(rubricCriterion)
            }
        }
    }
    
    
}
