//
//  CKISectionNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKISectionNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchSectionsForCourse() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)

        client.fetchSectionsForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/sections", "CKISection returned API path for testFetchSectionsForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKISection API Interaction Method was incorrect")
    }

    func testFetchSectionWithID() {
        let client = MockCKIClient()
        let sectionID = "1"
        
        client.fetchSectionWithID(sectionID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/sections/1", "CKISection returned API path for testFetchSectionWithID was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKISection API Interaction Method was incorrect")
    }
}
