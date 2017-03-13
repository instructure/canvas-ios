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

class CKILiveAssessmentTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let liveAssessmentDictionary = Helpers.loadJSONFixture("live_assessment") as NSDictionary
        var live: CKILiveAssessment? = nil
        let liveAssessment = CKILiveAssessment(fromJSONDictionary: liveAssessmentDictionary)
        
        XCTAssertEqual(liveAssessment.id!, "42", "LiveAssessment id did not parse correctly")
        XCTAssertEqual(liveAssessment.outcomeID!, "10", "LiveAssessment outcome id did not parse correctly")
        XCTAssertEqual(CKILiveAssessment.keyForJSONAPIContent()!, "assessments", "LiveAssessment keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(liveAssessment.path!, "/api/v1/live_assessments/42", "LiveAssessment path did not parse correctly")
    }
}
