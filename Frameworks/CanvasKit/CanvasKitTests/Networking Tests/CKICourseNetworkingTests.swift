//
//  CKICourseNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKICourseNetworkingTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchCourseWithCourseID() {
        var courseID = "7"
        var client = MockCKIClient()
        client.fetchCourseWithCourseID(courseID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/\(courseID)", "Returned API path for testFetchCourseWithCourseID was incorrect")
    }

    func testFetchCoursesForCurrentUser() {
        var client = MockCKIClient()
        client.fetchCoursesForCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses", "Returned API path for testFetchCoursesForCurrentUser was incorrect")
    }
    
    func testFetchCoursesForCurrentUserCurrentDomain() {
        var client = MockCKIClient()
        client.fetchCoursesForCurrentUserCurrentDomain()
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses", "Returned API path for testFetchCoursesForCurrentUserCurrentDomain was incorrect")
    }
    
    func testCourseWithUpdatedPermissionsSignalForCourse() {
        var client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        client.courseWithUpdatedPermissionsSignalForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1", "Returned API path for testCourseWithUpdatedPermissionsSignalForCourse was incorrect")
    }
}
