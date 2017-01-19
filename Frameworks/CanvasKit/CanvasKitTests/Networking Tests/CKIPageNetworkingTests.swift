//
//  CKIPageNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIPageNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchPagesForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchPagesForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/pages", "CKIPage returned API path for testFetchPagesForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }

    func testFetchPageForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let pageID = "1"
        
        client.fetchPage(pageID, forContext: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/pages/1", "CKIPage returned API path for testFetchPageForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }

    func testFetchFrontPageForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchFrontPageForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/front_page", "CKIPage returned API path for testFetchFrontPageForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPage API Interaction Method was incorrect")
    }
}
