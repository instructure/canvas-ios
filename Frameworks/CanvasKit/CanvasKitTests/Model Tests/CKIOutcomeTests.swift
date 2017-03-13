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

class CKIOutcomeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let outcomeDictionary = Helpers.loadJSONFixture("outcome") as NSDictionary
        let outcome = CKIOutcome(fromJSONDictionary: outcomeDictionary)
        
        XCTAssertEqual(outcome.title!, "Outcome title", "Outcome title did not parse correctly")
// The courseID property is not included in the Outcome object from the API. I think it should not be part of the class
// XCTAssertEqual(outcome.courseID!, "____", "Outcome courseID did not parse correctly")
        XCTAssertEqual(outcome.details!, "Outcome description", "Outcome details did not parse correctly")
        XCTAssertEqual(outcome.contextType!, "Account", "Outcome contextType did not parse correctly")
        XCTAssertEqual(outcome.contextID!, "1", "Outcome contextID did not parse correctly")
        XCTAssertEqual(outcome.url!, "/api/v1/outcomes/1", "Outcome url did not parse correctly")
        XCTAssertEqual(outcome.pointsPossible!, 5, "Outcome pointsPossible did not parse correctly")
        XCTAssertEqual(outcome.masteryPoints!, 3, "Outcome masteryPoints did not parse correctly")
        XCTAssertEqual(outcome.id!, "1", "Outcome id did not parse correctly")
        XCTAssertEqual(outcome.path!, "/api/v1/outcomes/1", "Outcome path did not parse correctly")
    }
}
