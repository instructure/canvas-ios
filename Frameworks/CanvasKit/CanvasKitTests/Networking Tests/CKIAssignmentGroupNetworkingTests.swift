//
//  CKIAssignmentGroupNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIAssignmentGroupNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchAssignmentGroupsForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchAssignmentGroupsForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/assignment_groups", "CKIAssignmentGroups returned API path for testFetchAssignmentGroupsForContext was incorrect")
    }
}
