//
//  CKIExternalToolNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIExternalToolNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchExternalToolsForCourse() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchExternalToolsForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/external_tools", "CKIExternalTool returned API path for testFetchExternalToolsForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIExternalTool API Interaction Method was incorrect")
    }

    func testFetchSessionlessLaunchURLWithURL() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let url = "http://lti-tool-provider.herokuapp.com/lti_tool"
        
        client.fetchSessionlessLaunchURLWithURL(url, course: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/external_tools/sessionless_launch", "CKIExternalTool returned API path for testFetchSessionlessLaunchURLWithURL was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIExternalTool API Interaction Method was incorrect")
    }
    
    func testFetchExternalToolForCourseWithExternalToolID() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let externalToolID = "24506"
        
        client.fetchExternalToolForCourseWithExternalToolID(externalToolID, course: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/external_tools/24506", "CKIExternalTool returned API path for testFetchExternalToolForCourseWithExternalToolID was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIExternalTool API Interaction Method was incorrect")
    }
}
