//
//  CKIPollSubmissionTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIPollSubmissionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pollSubmissionDictionary = Helpers.loadJSONFixture("poll_submission") as NSDictionary
        let pollSubmission = CKIPollSubmission(fromJSONDictionary: pollSubmissionDictionary)
        
        XCTAssertEqual(pollSubmission.id!, "1023", "Poll id was not parsed correctly")
        XCTAssertEqual(pollSubmission.pollChoiceID!, "155", "Poll pollChoiceID was not parsed correctly")
        XCTAssertEqual(pollSubmission.userID!, "4555", "Poll userID was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let date = formatter.dateFromString("2013-11-07T13:16:18Z")
        XCTAssertEqual(pollSubmission.created!, date, "Poll created was not parsed correctly")
        XCTAssertEqual(CKIPollSubmission.keyForJSONAPIContent()!, "poll_submissions", "CKIPollSubmission keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(pollSubmission.path!, "/api/v1/poll_submissions/1023", "Poll created was not parsed correctly")

    }
}
