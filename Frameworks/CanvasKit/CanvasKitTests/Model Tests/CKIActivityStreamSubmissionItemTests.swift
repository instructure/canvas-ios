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
