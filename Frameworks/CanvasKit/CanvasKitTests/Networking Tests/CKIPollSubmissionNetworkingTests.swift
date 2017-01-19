//
//  CKIPollSubmissionNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKIPollSubmissionNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreatePollSubmission() {
        let client = MockCKIClient()
        let pollSubmissionDictionary = Helpers.loadJSONFixture("poll_submission") as NSDictionary
        let pollSubmission = CKIPollSubmission(fromJSONDictionary: pollSubmissionDictionary)
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        let pollSessionDictionary = Helpers.loadJSONFixture("poll_session") as NSDictionary
        let pollSession = CKIPollSession(fromJSONDictionary: pollSessionDictionary)
        
        client.createPollSubmission(pollSubmission, forPoll: poll, pollSession: pollSession)
        XCTAssertEqual(client.capturedPath!, "/api/v1/poll_sessions/1023/poll_submissions", "CKIPollSubmission returned API path for testCreatePollSubmission was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Create, "CKIPollSubmission API Interaction Method was incorrect")
    }
}
