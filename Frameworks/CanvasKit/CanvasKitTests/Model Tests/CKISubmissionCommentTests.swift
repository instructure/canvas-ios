//
//  CKISubmissionCommentTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/14/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

import XCTest

class CKISubmissionCommentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {

        let submissionCommentDictionary = Helpers.loadJSONFixture("submission_comment") as NSDictionary
        let submissionComment = CKISubmissionComment(fromJSONDictionary: submissionCommentDictionary)
        
        XCTAssertEqual(submissionComment.id!, "37", "Submission Comment ID was not parsed correctly")
        XCTAssertEqual(submissionComment.comment!, "Well here's the thing...", "Submission Comment comment was not parsed correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let createdAtDate = formatter.dateFromString("2012-01-01T01:00:00Z")
        
        XCTAssertEqual(submissionComment.createdAt!, createdAtDate, "Submission Comment createdAt date was not parsed correctly")
        XCTAssertEqual(submissionComment.authorID!, "134", "Submission Comment authorID was not parsed correctly")
        XCTAssertEqual(submissionComment.authorName!, "Toph Beifong", "Submission Comment authorName was not parsed correctly")
        
    }
}
