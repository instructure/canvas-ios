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

class CKIRubricTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let rubricDictionary = Helpers.loadJSONFixture("rubric") as NSDictionary
        let rubric = CKIRubric(fromJSONDictionary: rubricDictionary)
        
        //I don't think these tests are very useful because I don't think the rubric.h/.m class is necessary
        XCTAssertEqual(rubric.title!, "Made Up Title", "rubric id did not parse correctly")
        XCTAssertEqual(rubric.pointsPossible, 10.5, "rubric pointsPossible did not parse correctly")
        XCTAssertFalse(rubric.allowsFreeFormCriterionComments, "rubric allowsFreeFormCriterionComments did not parse correctly")
    }
}
