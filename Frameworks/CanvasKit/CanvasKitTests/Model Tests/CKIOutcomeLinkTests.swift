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

class CKIOutcomeLinkTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let outcomeLinkDictionary = Helpers.loadJSONFixture("outcome_link") as NSDictionary
        let outcomeLink = CKIOutcomeLink(fromJSONDictionary: outcomeLinkDictionary)
        
        XCTAssertEqual(outcomeLink.contextType!, "Account", "outcomeLink contextType did not parse correctly")
        XCTAssertEqual(outcomeLink.contextID!, "1", "outcomeLink contextID did not parse correctly")
        XCTAssertEqual(outcomeLink.url!, "/api/v1/account/1/outcome_groups/1/outcomes/1", "outcomeLink url did not parse correctly")
        XCTAssertEqual(outcomeLink.path!, "/api/v1/outcomes", "outcomeLink url did not parse correctly")
        XCTAssertNil(outcomeLink.outcome, "outcomeLink outcome did not parse correctly")
        XCTAssertNil(outcomeLink.outcomeGroup, "outcomeGroup details did not parse correctly")
    }
}
