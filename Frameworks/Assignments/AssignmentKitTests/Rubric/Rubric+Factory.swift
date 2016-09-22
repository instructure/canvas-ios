//
//  Rubric+Factory.swift
//  Assignments
//
//  Created by Ben Kraus on 7/29/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import AssignmentKit
import CoreData

extension Rubric {
    static func build(inContext context: NSManagedObjectContext, courseID: String = "1140383", assignmentID: String = "9091235", title: String = "", freeFormCriterionComments: Bool = false, pointsPossible: NSNumber = NSNumber(float: 10.0)) -> Rubric {
        let rubric = Rubric(inContext: context)
        rubric.courseID = courseID
        rubric.assignmentID = assignmentID
        rubric.title = title
        rubric.freeFormCriterionComments = freeFormCriterionComments
        rubric.pointsPossible = pointsPossible
        return rubric
    }
}