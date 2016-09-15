//
//  AssignmentGroup+Factory.swift
//  Assignments
//
//  Created by Nathan Armstrong on 5/30/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import CoreData
@testable import AssignmentKit

extension AssignmentGroup {
    static func build(context: NSManagedObjectContext,
                      id: String = "1",
                      name: String = "Assignments",
                      position: Int32 = 0,
                      weight: Double = 0.0,
                      assignments: Set<Assignment> = []
    ) -> AssignmentGroup {
        let assignmentGroup = AssignmentGroup.create(inContext: context)
        assignmentGroup.id = id
        assignmentGroup.name = name
        assignmentGroup.position = position
        assignmentGroup.weight = weight
        assignmentGroup.assignments = assignments
        return assignmentGroup
    }
}
