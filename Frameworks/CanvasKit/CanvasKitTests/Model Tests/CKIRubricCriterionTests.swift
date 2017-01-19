//
//  CKIRubricCriterionTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIRubricCriterionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let rubricCriterionDictionary = Helpers.loadJSONFixture("rubric_criterion") as NSDictionary
        let rubricCriterion = CKIRubricCriterion(fromJSONDictionary: rubricCriterionDictionary)
        
        XCTAssertEqual(rubricCriterion.points, 9.5, "rubric points was not parsed correctly")
        XCTAssertEqual(rubricCriterion.id!, "crit1", "rubric crit1 was not parsed correctly")
        XCTAssertEqual(rubricCriterion.criterionDescription!, "Criterion 1", "rubric criterionDescription was not parsed correctly")
        XCTAssertEqual(rubricCriterion.longDescription!, "Here is a longer description.", "rubric longDescription was not parsed correctly")
        XCTAssertEqual(rubricCriterion.ratings.count, 3, "rubric ratings was not parsed correctly")
        XCTAssertNotNil(rubricCriterion.selectedRating, "rubric selectedRating was not parsed correctly")

    }
}
