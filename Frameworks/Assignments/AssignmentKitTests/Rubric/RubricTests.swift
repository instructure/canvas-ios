//
//  RubricTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/14/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import Marshal
import DoNotShipThis
@testable import AssignmentKit


class RubricTests: UnitTestCase {

    func testUpdateRubricWithJSON() {
        attempt{
            let session = Session.ns
            let context = try session.assignmentsManagedObjectContext()
            let rubric: Rubric = Rubric.create(inContext: context)
            
            try rubric.updateValues([], rubricSettingsJSON: rubricSettings, assignmentID: "259883", inContext:context)
            
            XCTAssertEqual("259883", rubric.assignmentID)
            XCTAssertEqual("Food Network Cooking", rubric.title)
            XCTAssertEqual(1900, rubric.pointsPossible)
            XCTAssertEqual(false, rubric.freeFormCriterionComments)
        }
    }
    
    private var rubricSettings: JSONObject {
        return [
            "id": 259883,
            "title": "Food Network Cooking",
            "points_possible": 1900,
            "free_form_criterion_comments": false
        ]
    }
    
}
