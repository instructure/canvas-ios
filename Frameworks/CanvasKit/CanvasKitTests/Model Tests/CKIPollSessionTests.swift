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
