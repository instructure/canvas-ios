//
//  CKIRubricTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/18/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIRubricTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let rubricDictionary = Helpers.loadJSONFixture("rubric") as NSDictionary
        let rubric = CKIRubric(fromJSONDictionary: rubricDictionary)
        
        //I don't think these tests are very useful because I don't think the rubric.h/.m class is necessary
        XCTAssertEqual(rubric.title!, "Made Up Title", "rubric id did not parse correctly")
        XCTAssertEqual(rubric.pointsPossible, 10.5, "rubric pointsPossible did not parse correctly")
        XCTAssertFalse(rubric.allowsFreeFormCriterionComments, "rubric allowsFreeFormCriterionComments did not parse correctly")
    }
}
