//
//  CKIActivityStreamItemNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIActivityStreamItemNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchActivityStream() {
        var client = MockCKIClient()
        client.fetchActivityStream()
        if client.capturedPath? != nil {
             XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/activity_stream", "Returned API path for testFetchActivityStream was incorrect")
        } else {
            XCTAssertNotNil(client.capturedPath, "CKIActivityStreamItem path was not initialized in CKIClient")
        }
    }
    
    func testFetchActivityStreamForContext() {
        var client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        client.fetchActivityStreamForContext(course)
        if client.capturedPath? != nil{
            XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/activity_stream", "Returned API path for testFetchActivityStreamForContext was incorrect")
        } else {
            XCTAssertNotNil(client.capturedPath, "CKIActivityStreamItem path was not initialized in CKIClient")
        }
    }
}
