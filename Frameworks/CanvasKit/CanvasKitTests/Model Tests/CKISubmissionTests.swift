//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import XCTest

class CKISubmissionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let submissionDictionary = Helpers.loadJSONFixture("submission") as NSDictionary
        let submission = CKISubmission(fromJSONDictionary: submissionDictionary)
        
        XCTAssertEqual(submission.assignmentID!, "1697207", "Submission assignment id was not parsed correctly")
        
        XCTAssertEqual(submission.attempt, UInt(1), "Submission attempt was not parsed correctly")
        
        XCTAssertEqual(submission.body!, "Here is a body", "Submission body was not parsed correctly")
        
        XCTAssertEqual(submission.grade!, "A-", "Submission grade was not parsed correctly")
        
        XCTAssert(submission.gradeMatchesCurrentSubmission, "Submission gradeMatchesCurrentSubmission was not parsed correctly")
        
        var url = NSURL(string:"https://www.instructure.com/courses/123/assignments/1697207/submissions/2695688")
        XCTAssertEqual(submission.url!, url!, "Submission url was not parsed correctly")
        
        url = NSURL(string:"http://example.com/courses/255/assignments/543/submissions/134")
        XCTAssertEqual(submission.htmlURL!, url!, "Submission htmlURL was not parsed correctly")
        
        url = NSURL(string:"https://www.instructure.com/courses/123/assignments/1697207/submissions/2695688?preview=1")
        XCTAssertEqual(submission.previewURL!, url!, "Submission previewURL was not parsed correctly")
        
        XCTAssertEqual(submission.score, 8.5, "Submission score was not parsed correctly")
        
        var formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        
        var date = formatter.dateFromString("2013-08-29T23:03:19-06:00")
        XCTAssertEqual(submission.submittedAt!, date, "Submission submittedAt was not parsed correctly")
        
        XCTAssertEqual(submission.submissionType!, "online_upload", "Submission submissionType was not parsed correctly")
        
        XCTAssertEqual(submission.userID!, "12", "Submission userID was not parsed correctly")
        
        XCTAssertEqual(submission.graderID!, "123", "Submission graderID was not parsed correctly")

        XCTAssert(submission.late, "Submission late was not parsed correctly")

//        XCTAssertNotNil(submission.comments, "Submission comments was not parsed correctly")
        
        XCTAssertNotNil(submission.attachments, "Submission attachments was not parsed correctly")
        
        XCTAssertNil(submission.mediaComment, "Submission mediaComment was not parsed correctly")
        
        XCTAssertNil(submission.assignment, "Submission assignment was not parsed correctly")
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
