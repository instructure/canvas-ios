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
