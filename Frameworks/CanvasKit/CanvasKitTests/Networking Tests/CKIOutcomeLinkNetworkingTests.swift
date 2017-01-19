//
//  CKIOutcomeLinkNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIOutcomeLinkNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchOutcomeLinksForOutcomeGroup() {
        let outcomeGroupDictionary = Helpers.loadJSONFixture("outcome_group") as NSDictionary
        let outcomeGroup = CKIOutcomeGroup(fromJSONDictionary: outcomeGroupDictionary)
        let client = MockCKIClient()
        
        client.fetchOutcomeLinksForOutcomeGroup(outcomeGroup)
        XCTAssertEqual(client.capturedPath!, "/api/v1/outcome_groups/1/outcomes", "CKIOutcomeLink returned API path for testFetchOutcomeLinksForOutcomeGroup was incorrect")
    }
}
