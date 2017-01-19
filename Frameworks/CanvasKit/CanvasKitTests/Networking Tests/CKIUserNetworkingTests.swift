//
//  CKIUserNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIUserNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testfetchUsersForContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let dictionary = ["include": ["avatar_url", "enrollments"]];
        
        client.fetchUsersForContext(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/users", "CKIUser returned API path for testfetchUsersForContext was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, dictionary.count, "CKIUser returned API parameters for testfetchUsersForContext was incorrect")
    }

    func testFetchUsersWithParametersAndContext() {
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let client = MockCKIClient()
        let dictionary = ["include": ["avatar_url", "enrollments"]];
        
        client.fetchUsersWithParameters(dictionary, context: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/users", "CKIUser returned API path for testFetchUsersWithParametersAndContext was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, dictionary.count, "CKIUser returned API parameters for testFetchUsersWithParametersAndContext was incorrect")
    }
    
    func testFetchCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/profile", "CKIUser returned API path for testFetchCurrentUser was incorrect")
    }
}
