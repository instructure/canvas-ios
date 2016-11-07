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
    
    

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import EnrollmentKit

class GradeAPITests: XCTestCase {
    let session = Session.art

    func testGradeAPI_getGrades_setsCourseIDInURL() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: nil)
        XCTAssertEqual("/api/v1/courses/1/enrollments", request.URL?.relativePath, "it should have the correct path")
    }

    func testGradeAPI_getGrades_parametersWhenGradingPeriodIDIsNil() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: nil)
        XCTAssertEqual("enrollment_type=student&per_page=99&user_id=self", request.URL?.query, "it should have the correct parameters")
    }

    func testGradeAPI_getGrades_parametersWhenGradingPeriodIDIsNotNil() {
        let request = try! GradeAPI.getGrades(session, courseID: "1", gradingPeriodID: "1")
        XCTAssertEqual("enrollment_type=student&grading_period_id=1&per_page=99&user_id=self", request.URL?.query, "it should have the correct parameters")
    }
}
