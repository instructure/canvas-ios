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

class CKIAssignmentGroupTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let assignmentGroupDictionary = Helpers.loadJSONFixture("assignment_group_with_assignments") as NSDictionary?
        let assignmentGroup = CKIAssignmentGroup(fromJSONDictionary: assignmentGroupDictionary)
        
        XCTAssertEqual(assignmentGroup.id!, "1030331", "Assignment Group id did not parse correctly")
        XCTAssertEqual(assignmentGroup.name!, "flashcards", "Assignment Group name did not parse correctly")
        XCTAssertEqual(assignmentGroup.position, 1, "Assignment Group position did not parse correctly")
        XCTAssertEqual(assignmentGroup.weight, 25, "Assignment Group weight did not parse correctly")
        XCTAssertEqual(assignmentGroup.assignments.count, 5, "Assignment Group assignments did not parse correctly")
        XCTAssertEqual(assignmentGroup.rules.count, 0, "Assignment Group rules did not parse correctly")
    }
}
