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

public final class RubricAssessment: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber?
    
    @NSManaged internal (set) public var submission: Submission
}


import Marshal


extension RubricAssessment {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let assessmentID: String = try json.stringID("id")
        let submissionID: String = try json.stringID("submissionID")
        return NSPredicate(format: "%K == %@ && %K == %@", "id", assessmentID, "submission.id", submissionID)
    }
    
    @objc public func updateValues(_ assessmentID: String, submission: Submission, json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = assessmentID
        comments = try json <| "comments"
        points = try json <| "points"
        
        self.submission = submission
    }
}

