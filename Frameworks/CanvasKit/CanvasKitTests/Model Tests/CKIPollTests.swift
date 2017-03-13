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

class CKIPollTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pollDictionary = Helpers.loadJSONFixture("poll") as NSDictionary
        let poll = CKIPoll(fromJSONDictionary: pollDictionary)
        
        XCTAssertEqual(poll.id!, "1023", "Poll id was not parsed correctly")
        XCTAssertEqual(poll.question!, "What do you consider most important to your learning in this course?", "Poll question was not parsed correctly")
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let date = formatter.dateFromString("2014-01-07T15:16:18Z")
        XCTAssertEqual(poll.created!, date, "Poll created was not parsed correctly")
        XCTAssertEqual(CKIPoll.keyForJSONAPIContent()!, "polls", "CKIPoll keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(poll.path!, "/api/v1/polls/1023", "Poll path was not parsed correctly")
    }
}
