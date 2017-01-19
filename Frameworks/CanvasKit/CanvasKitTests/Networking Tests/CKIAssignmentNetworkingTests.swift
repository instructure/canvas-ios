//
//  CKIAssignmentNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIAssignmentNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testNotReallyMockingButKindOf() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchAssignmentsForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/\(course.id)/assignments", "Returned API path for fetchCourseWithCourseID was incorrect")
    }
}
