//
//  CKIOutcomeNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIOutcomeNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchOutcomeLinksForOutcomeGroup() {
        let outcomeDictionary = Helpers.loadJSONFixture("outcome") as NSDictionary
        let outcome = CKIOutcome(fromJSONDictionary: outcomeDictionary)
        let client = MockCKIClient()
        let courseID = "1"
        
        client.refreshOutcome(outcome, courseID: courseID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/outcomes/1", "CKIOutcome returned API path for testFetchOutcomeLinksForOutcomeGroup was incorrect")
    }
}
