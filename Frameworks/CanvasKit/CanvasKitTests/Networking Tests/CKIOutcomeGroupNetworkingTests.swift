//
//  CKIOutcomeGroupNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIOutcomeGroupNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchGroupsForAccount() {
        let client = MockCKIClient()
        let accountID = "170000000000002"
        
        client.fetchGroupsForAccount(accountID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/accounts/170000000000002/groups", "CKIOutcomeGroup returned API path for testFetchGroupsForAccount was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIOutcomeGroup API Interaction was incorrect")
    }
    
    func testFetchRootOutcomeGroupForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchRootOutcomeGroupForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/root_outcome_group", "CKIOutcomeGroup returned API path for testFetchRootOutcomeGroupForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIOutcomeGroup API Interaction was incorrect")
    }
    
    func testFetchOutcomeGroupForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let outcomeGroupID = "1"
        let client = MockCKIClient()
        
        client.fetchOutcomeGroupForCourse(course, id: outcomeGroupID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/outcome_groups/1", "CKIOutcomeGroup returned API path for testFetchOutcomeGroupForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIOutcomeGroup API Interaction was incorrect")
    }
    
    func testFetchSubGroupsForOutcomeGroup() {
        let outcomeGroupDictionary = Helpers.loadJSONFixture("outcome_group") as NSDictionary
        let outcomeGroup = CKIOutcomeGroup(fromJSONDictionary: outcomeGroupDictionary)
        let client = MockCKIClient()
        
        client.fetchSubGroupsForOutcomeGroup(outcomeGroup)
        XCTAssertEqual(client.capturedPath!, "/api/v1/outcome_groups/1/subgroups", "CKIOutcomeGroup returned API path for testFetchSubGroupsForOutcomeGroup was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIOutcomeGroup API Interaction was incorrect")
    }
}
