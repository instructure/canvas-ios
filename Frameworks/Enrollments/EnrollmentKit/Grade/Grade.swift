//
//  Grade.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 5/12/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
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
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let gradingPeriodID: String? = try json.stringID("grading_period_id")
        let courseID: String = try json.stringID("course_id")

        return Grade.predicate(courseID, gradingPeriodID: gradingPeriodID)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
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
