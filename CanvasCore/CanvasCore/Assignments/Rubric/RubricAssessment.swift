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

public final class RubricAssessment: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber?
    
    @NSManaged internal (set) public var submission: Submission
}


import Marshal


extension RubricAssessment {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let assessmentID: String = try json.stringID("id")
        let submissionID: String = try json.stringID("submissionID")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", assessmentID, "submission.id", submissionID)
    }
    
    public func updateValues(_ assessmentID: String, submission: Submission, json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = assessmentID
        comments = try json <| "comments"
        points = try json <| "points"
        
        self.submission = submission
    }
}

