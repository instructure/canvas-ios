//
//  CKIFavoriteNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIFavoriteNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchFavoriteCourses() {
        let client = MockCKIClient()
        
        client.fetchFavoriteCourses()
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/favorites/courses", "CKIFavorite returned API path for testFetchFavoriteCourses was incorrect")
    }
    
    func testAddCourseToFavoritesWithSuccessFailure() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.addCourseToFavorites(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/favorites/courses/1", "CKIFavorite returned API path for testAddCourseToFavoritesWithSuccessFailure was incorrect")
    }

    func testremoveCourseFromFavoritesWithSuccessFailure() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.removeCourseFromFavorites(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/users/self/favorites/courses/1", "CKIFavorite returned API path for testAddCourseToFavoritesWithSuccessFailure was incorrect")
    }
}
