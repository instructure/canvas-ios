//
//  CKILiveAssessmentResultsTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 8/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKILiveAssessmentResultsTests: XCTestCase {

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
        let liveAssessmentResult = CKILiveAssessmentResult(fromJSONDictionary: liveAssessmentDictionary)
        
        XCTAssertEqual(liveAssessmentResult.id!, "42", "LiveAssessmentResult id did not parse correctly")
        XCTAssertTrue(liveAssessmentResult.passed, "LiveAssessmentResult passed did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2014-05-13T00:01:57-06:00")

        XCTAssertEqual(liveAssessmentResult.assessedAt!, date,"LiveAssessmentResult assessedAt did not parse correctly")
        XCTAssertEqual(liveAssessmentResult.assessedUserID!, "42", "LiveAssessmentResult assessedUserID did not parse correctly")
        XCTAssertEqual(liveAssessmentResult.assessorUserID!, "23", "LiveAssessmentResult assessorUserID did not parse correctly")
        XCTAssertEqual(CKILiveAssessmentResult.keyForJSONAPIContent()!, "results", "LiveAssessmentResult keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(liveAssessmentResult.path!, "/api/v1/results/42", "LiveAssessmentResult path did not parse correctly")
    }
}
