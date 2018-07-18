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
