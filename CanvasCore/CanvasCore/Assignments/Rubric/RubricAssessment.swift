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

