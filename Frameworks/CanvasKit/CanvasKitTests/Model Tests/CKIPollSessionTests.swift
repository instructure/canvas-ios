//
//  CKIPollSessionTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest
import CanvasKit

class CKIPollSessionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pollSessionDictionary = Helpers.loadJSONFixture("poll_session") as NSDictionary
        let pollSession = CKIPollSession(fromJSONDictionary: pollSessionDictionary)
        
        XCTAssertEqual(pollSession.id!, "1023", "pollSession id was not parsed correctly")
        XCTAssertTrue(pollSession.isPublished, "pollSession isCorrect was not parsed correctly")
        XCTAssertTrue(pollSession.hasPublicResults, "pollSession hasPublicResults was not parsed correctly")
        XCTAssertTrue(pollSession.hasSubmitted, "pollSession hasSubmitted was not parsed correctly")
        XCTAssertEqual(pollSession.courseID!, "1111", "pollSession courseID was not parsed correctly")
        XCTAssertEqual(pollSession.sectionID!, "444", "pollSession sectionID was not parsed correctly")
        XCTAssertEqual(pollSession.pollID!, "55", "pollSession pollID was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let date = formatter.dateFromString("2014-01-07T15:16:18Z")
        XCTAssertEqual(pollSession.created!, date, "Poll created was not parsed correctly")

        XCTAssertEqual(pollSession.results.count, 4, "pollSession results was not parsed correctly")
        XCTAssertNil(pollSession.submissions, "pollSession submissions was not parsed correctly")
        XCTAssertEqual(CKIPollSession.keyForJSONAPIContent()!, "poll_sessions", "CKIPollSession keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(pollSession.path!, "/api/v1/poll_sessions/1023", "pollSession path was not parsed correctly")
    }
}
