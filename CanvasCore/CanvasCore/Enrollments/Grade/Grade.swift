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

import Marshal

public final class Grade: NSManagedObject {
    @NSManaged internal (set) public var gradingPeriodID: String?
    @NSManaged internal (set) public var currentGrade: String?
    @NSManaged internal (set) public var currentScore: NSNumber?
    @NSManaged internal (set) public var finalGrade: String?
    @NSManaged internal (set) public var finalScore: NSNumber?

    @NSManaged internal (set) public var course: Course
}

extension Grade: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let gradingPeriodID: String? = try json.stringID("grading_period_id")
        let courseID: String = try json.stringID("course_id")

        return Grade.predicate(courseID, gradingPeriodID: gradingPeriodID)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        gradingPeriodID = try json.stringID("grading_period_id")
        if let gradesJSON: JSONObject = try json <| "grades" {
            currentGrade    = try gradesJSON <| "current_grade"
            currentScore    = try gradesJSON <| "current_score"
            finalGrade      = try gradesJSON <| "final_grade"
            finalScore      = try gradesJSON <| "final_score"
        }

        let courseID: String = try json.stringID("course_id")
        if let course: Course = try context.findOne(withValue: courseID, forKey: "id") {
            self.course = course
        }
    }
}
