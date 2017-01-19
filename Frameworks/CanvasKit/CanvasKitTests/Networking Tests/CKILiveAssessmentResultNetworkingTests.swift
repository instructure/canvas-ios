//
//  CKILiveAssessmentResultNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKILiveAssessmentResultNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*
    func testCreateLiveAssessments() {
        let client = MockCKIClient()
        let liveAssessmentDictionary = Helpers.loadJSONFixture("live_assessment") as NSDictionary
        let liveAssessment = CKILiveAssessment(fromJSONDictionary: liveAssessmentDictionary)
        
        client.createLiveAssessments([liveAssessment])
        
        // TODO not currently testible with default of nil for context in CKILiveAssessment
        // get CKILiveAssessmentNetworkingTests working and this will work
        XCTAssertEqual(client.capturedPath!, "/api/v1/<not sure yet what to put here>", "CKILiveAssessment returned API path for testCreateLiveAssessments was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKILiveAssessment API Interaction Method was incorrect")
    }
*/
}
