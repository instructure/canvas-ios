//
//  CKIOutcomeTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIOutcomeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let outcomeDictionary = Helpers.loadJSONFixture("outcome") as NSDictionary
        let outcome = CKIOutcome(fromJSONDictionary: outcomeDictionary)
        
        XCTAssertEqual(outcome.title!, "Outcome title", "Outcome title did not parse correctly")
// The courseID property is not included in the Outcome object from the API. I think it should not be part of the class
// XCTAssertEqual(outcome.courseID!, "____", "Outcome courseID did not parse correctly")
        XCTAssertEqual(outcome.details!, "Outcome description", "Outcome details did not parse correctly")
        XCTAssertEqual(outcome.contextType!, "Account", "Outcome contextType did not parse correctly")
        XCTAssertEqual(outcome.contextID!, "1", "Outcome contextID did not parse correctly")
        XCTAssertEqual(outcome.url!, "/api/v1/outcomes/1", "Outcome url did not parse correctly")
        XCTAssertEqual(outcome.pointsPossible!, 5, "Outcome pointsPossible did not parse correctly")
        XCTAssertEqual(outcome.masteryPoints!, 3, "Outcome masteryPoints did not parse correctly")
        XCTAssertEqual(outcome.id!, "1", "Outcome id did not parse correctly")
        XCTAssertEqual(outcome.path!, "/api/v1/outcomes/1", "Outcome path did not parse correctly")
    }
}
