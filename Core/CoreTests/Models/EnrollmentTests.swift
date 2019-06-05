//
// Copyright (C) 2018-present Instructure, Inc.
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
@testable import Core

class EnrollmentTests: CoreTestCase {
    func testEnrollmentStateInitRawValue() {
        // Converting to & from String is needed by database models
        XCTAssertEqual(EnrollmentState(rawValue: "invited"), .invited)
        XCTAssertEqual(EnrollmentState.invited.rawValue, "invited")
    }

    func testEnrollmentRoleInitRawValue() {
        // Converting to & from String is needed by database models
        XCTAssertEqual(EnrollmentRole(rawValue: "StudentEnrollment"), .student)
        XCTAssertEqual(EnrollmentRole.student.rawValue, "StudentEnrollment")
    }

    func testUpdateFromAPI() {
        let apiEnrollment = APIEnrollment.make()

        let model: Enrollment = databaseClient.insert()
        model.update(fromApiModel: apiEnrollment, course: nil, in: databaseClient)

        XCTAssertEqual(model.role, .student)
        XCTAssertEqual(model.roleID, apiEnrollment.role_id)
        XCTAssertEqual(model.state, apiEnrollment.enrollment_state)
        XCTAssertEqual(model.userID, apiEnrollment.user_id)
        XCTAssertEqual(model.multipleGradingPeriodsEnabled, apiEnrollment.multiple_grading_periods_enabled)
        XCTAssertEqual(model.computedCurrentScore, apiEnrollment.computed_current_score)
        XCTAssertEqual(model.computedFinalScore, apiEnrollment.computed_final_score)
        XCTAssertEqual(model.currentPeriodComputedCurrentScore, apiEnrollment.current_period_computed_current_score)
        XCTAssertEqual(model.currentPeriodComputedFinalScore, apiEnrollment.current_period_computed_final_score)
    }

    func testHasRole() {
        //  given
        var data = Set<Enrollment>()
        let a = Enrollment.make()
        data.insert(a)

        //  when    // then
        XCTAssertFalse(data.hasRole(.teacher))
        XCTAssertTrue(data.hasRole(.student))
    }
}
