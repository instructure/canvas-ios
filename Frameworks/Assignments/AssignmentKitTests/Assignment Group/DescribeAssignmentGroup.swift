//
//  DescribeAssignmentGroup.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/25/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
@testable import AssignmentKit
import CoreData
import TooLegit
import Marshal

class AssignmentGroupTests: XCTestCase {

    // MARK: - Model

    func testAssignmentGroup_isValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.assignmentsManagedObjectContext()
            let group = AssignmentGroup.build(context)
            XCTAssert(group.isValid)
        }
    }

    func testAssignmentGroup_updateValues() {
        attempt {

            // Given
            let session = Session.inMemory
            let context = try session.assignmentsManagedObjectContext()
            let assignment = Assignment.build(context, assignmentGroupID: "1", gradingPeriodID: nil)
            let assignmentGroup = AssignmentGroup(inContext: context)
            let json = [
                "id": 1,
                "name": "Research",
                "position": 1,
                "group_weight": 0,
                "grading_period_id": 1,
                "assignments": [
                    ["id": 1]
                ]
            ]

            // When
            try assignmentGroup.updateValues(json, inContext: context)

            // Then
            XCTAssertEqual("1", assignmentGroup.id)
            XCTAssertEqual("Research", assignmentGroup.name)
            XCTAssertEqual(1, assignmentGroup.position)
            XCTAssertEqual(0, assignmentGroup.weight)
            XCTAssertEqual("1", assignment.gradingPeriodID)

        }
    }
}
