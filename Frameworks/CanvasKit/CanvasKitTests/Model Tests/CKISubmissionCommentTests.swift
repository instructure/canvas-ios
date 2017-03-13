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
