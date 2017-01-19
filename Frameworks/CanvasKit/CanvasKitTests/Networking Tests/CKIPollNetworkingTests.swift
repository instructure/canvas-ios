//
//  CKIPollNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIPollNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchPollsForCurrentUser() {
        let client = MockCKIClient()
        
        client.fetchPollsForCurrentUser()
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPoll API Interaction Method was incorrect")
    }

    func testFetchPollWithID() {
        let client = MockCKIClient()

        client.fetchPollWithID("1023")
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPoll API Interaction Method was incorrect")
    }

    func testCreatePoll() {
        let client = MockCKIClient()
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.createPoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls", "CKIPoll returned API path for testFetchPollsForCurrentUser was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIPoll API Interaction Method was incorrect")
    }
    
    func testDeletePoll() {
        let client = MockCKIClient()
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.deletePoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023", "CKIPoll returned API path for testDeletePoll was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Delete, "CKIPoll API Interaction Method was incorrect")
    }
}
