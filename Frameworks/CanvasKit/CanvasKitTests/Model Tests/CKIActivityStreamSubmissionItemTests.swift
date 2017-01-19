//
//  CKIActivityStreamSubmissionItemTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/17/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import UIKit
import XCTest

class CKIActivityStreamSubmissionItemTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let activityStreamSubmissionItemDictionary = Helpers.loadJSONFixture("activity_stream_submission_item") as NSDictionary
        let streamItem = CKIActivityStreamSubmissionItem(fromJSONDictionary: activityStreamSubmissionItemDictionary)
        
        //This is a special case in the API. The API for submissions, "Returns a Submission with its Course and Assignment data."
        //While this is passing it may not reflect the actual way this data is received
        XCTAssertEqual(streamItem.submissionID!, "1234", "Stream Submission Item id was not parsed correctly")
        XCTAssertEqual(streamItem.assignmentID!, "1234", "Stream Submission Item id was not parsed correctly")
    }
}
