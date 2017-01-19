//
//  CKILiveAssessmentTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/31/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest
import CanvasKit

class CKILiveAssessmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let liveAssessmentDictionary = Helpers.loadJSONFixture("live_assessment") as NSDictionary
        var live: CKILiveAssessment? = nil
        let liveAssessment = CKILiveAssessment(fromJSONDictionary: liveAssessmentDictionary)
        
        XCTAssertEqual(liveAssessment.id!, "42", "LiveAssessment id did not parse correctly")
        XCTAssertEqual(liveAssessment.outcomeID!, "10", "LiveAssessment outcome id did not parse correctly")
        XCTAssertEqual(CKILiveAssessment.keyForJSONAPIContent()!, "assessments", "LiveAssessment keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(liveAssessment.path!, "/api/v1/live_assessments/42", "LiveAssessment path did not parse correctly")
    }
}
