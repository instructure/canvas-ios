//
//  CKIQuizNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIQuizNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchQuizForCourse() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchQuiz("5", forCourse: course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/quizzes/5", "CKIQuiz returned API path for testFetchQuizForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIQuiz API Interaction Method was incorrect")
    }
    
    func testFetchQuizzesForCourse() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        
        client.fetchQuizzesForCourse(course)
        XCTAssertEqual(client.capturedPath!, "/api/v1/courses/1/quizzes", "CKIQuiz returned API path for testFetchQuizForCourse was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIQuiz API Interaction Method was incorrect")
    }
}
