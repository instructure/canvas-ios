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

class CKIPollChoiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let pollChoiceDictionary = Helpers.loadJSONFixture("poll_choice") as NSDictionary
        let pollChoice = CKIPollChoice(fromJSONDictionary: pollChoiceDictionary)
        
        XCTAssertEqual(pollChoice.id!, "1023", "pollChoice id was not parsed correctly")
        XCTAssertTrue(pollChoice.isCorrect, "pollChoice isCorrect was not parsed correctly")
        XCTAssertEqual(pollChoice.text!, "Choice A", "pollChoice text was not parsed correctly")
        XCTAssertEqual(pollChoice.pollID!, 1779, "pollChoice pollID was not parsed correctly")
        XCTAssertEqual(pollChoice.index!, 1, "pollChoice index was not parsed correctly")
        XCTAssertEqual(CKIPollChoice.keyForJSONAPIContent()!, "poll_choices", "CKIPollChoice keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(pollChoice.path!, "/api/v1/poll_choices/1023", "pollChoice path was not parsed correctly")
    }
}
