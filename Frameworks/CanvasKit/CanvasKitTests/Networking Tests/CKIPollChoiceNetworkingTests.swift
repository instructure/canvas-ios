//
//  CKIPollChoiceNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIPollChoiceNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchPollChoicesForPoll() {
        let client = MockCKIClient()
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.fetchPollChoicesForPoll(poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023/poll_choices", "CKIPollChoice returned API path for testFetchPollCHoicesForPoll was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKIPollChoice API Interaction Method was incorrect")
    }

    func testCreatePollChoice() {
        let client = MockCKIClient()
        let pollChoiceDictionary = Helpers.loadJSONFixture("poll_choice") as NSDictionary
        let pollChoice = CKIPollChoice(fromJSONDictionary: pollChoiceDictionary)
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        client.createPollChoice(pollChoice, forPoll: poll)
        XCTAssertEqual(client.capturedPath!, "/api/v1/polls/1023/poll_choices", "CKIPollChoice returned API path for testCreatePollChoice was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIPollChoice API Interaction Method was incorrect")
    }
}
