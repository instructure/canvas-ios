//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
