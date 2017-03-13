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

class CKIOutcomeGroupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let outcomeGroupDictionary = Helpers.loadJSONFixture("outcome_group") as NSDictionary
        let outcomeGroup = CKIOutcomeGroup(fromJSONDictionary: outcomeGroupDictionary)
        
        XCTAssertEqual(outcomeGroup.title!, "Outcome group title", "Outcome title did not parse correctly")
        XCTAssertEqual(outcomeGroup.details!, "Outcome group description", "Outcome details did not parse correctly")
        XCTAssertEqual(outcomeGroup.contextType!, "Account", "Outcome contextType did not parse correctly")
        XCTAssertEqual(outcomeGroup.contextID!, "1", "Outcome contextID did not parse correctly")
        XCTAssertEqual(outcomeGroup.url!, "/api/v1/accounts/1/outcome_groups/1", "Outcome url did not parse correctly")
        XCTAssertEqual(outcomeGroup.subgroupsURL!, "/api/v1/accounts/1/outcome_groups/1/subgroups", "Outcome subgroupsURL did not parse correctly")
        XCTAssertEqual(outcomeGroup.outcomesURL!, "/api/v1/accounts/1/outcome_groups/1/outcomes", "Outcome outcomesURL did not parse correctly")
        XCTAssertNotNil(outcomeGroup.parent, "Outcome parent did not parse correctly")
        XCTAssertEqual(outcomeGroup.id!, "1", "Outcome id did not parse correctly")
        XCTAssertEqual(outcomeGroup.path!, "/api/v1/outcome_groups/1", "Outcome path did not parse correctly")
    }
}
