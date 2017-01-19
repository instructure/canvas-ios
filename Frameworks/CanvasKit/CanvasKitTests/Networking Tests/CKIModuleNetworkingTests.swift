//
//  CKIModuleNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIModuleNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchModulesForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        
        client.fetchModulesForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/modules", "CKIModule returned API path for testFetchModulesForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModule API Interaction Method was incorrect ")
    }

    func testFetchModuleWithIDForCourse() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let moduleID = "768"
        
        client.fetchModuleWithID(moduleID, forCourse: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/modules/768", "CKIModule returned API path for testFetchModuleWithIDForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIModule API Interaction Method was incorrect ")
    }
}
