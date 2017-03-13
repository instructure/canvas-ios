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

class CKILiveAssessmentResultsTests: XCTestCase {

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
        let liveAssessmentResult = CKILiveAssessmentResult(fromJSONDictionary: liveAssessmentDictionary)
        
        XCTAssertEqual(liveAssessmentResult.id!, "42", "LiveAssessmentResult id did not parse correctly")
        XCTAssertTrue(liveAssessmentResult.passed, "LiveAssessmentResult passed did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2014-05-13T00:01:57-06:00")

        XCTAssertEqual(liveAssessmentResult.assessedAt!, date,"LiveAssessmentResult assessedAt did not parse correctly")
        XCTAssertEqual(liveAssessmentResult.assessedUserID!, "42", "LiveAssessmentResult assessedUserID did not parse correctly")
        XCTAssertEqual(liveAssessmentResult.assessorUserID!, "23", "LiveAssessmentResult assessorUserID did not parse correctly")
        XCTAssertEqual(CKILiveAssessmentResult.keyForJSONAPIContent()!, "results", "LiveAssessmentResult keyForJSONAPIContent was not parsed correctly")
        XCTAssertEqual(liveAssessmentResult.path!, "/api/v1/results/42", "LiveAssessmentResult path did not parse correctly")
    }
}
