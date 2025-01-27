//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class GetEnrollmentsTests: CoreTestCase {

    func testCacheKey() {
        let testee = GetEnrollments(
            context: .course("someCourseID"),
            userID: "someUserID",
            gradingPeriodID: "somePeriodID",
            types: ["type1", "type2"],
            includes: [.avatar_url],
            states: [.invited, .deleted],
            roles: [.teacher, .custom("someCustomRole")]
        )

        XCTAssertEqual(testee.cacheKey, """
        courses/someCourseID/enrollments?\
        per_page=100\
        &include[]=avatar_url\
        &state[]=invited&state[]=deleted\
        &role[]=TeacherEnrollment&role[]=someCustomRole\
        &user_id=someUserID\
        &grading_period_id=somePeriodID\
        &type[]=type1&type[]=type2
        """)
    }

    func testScopeWithoutUserID() {
        let testee = GetEnrollments(
            context: .course("someCourseID")
        )

        XCTAssertEqual(testee.scope.predicate.predicateFormat, """
        canvasContextID == "course_someCourseID" \
        AND id != nil
        """)
    }

    func testScopeWithUserID() {
        let testee = GetEnrollments(
            context: .course("someCourseID"),
            userID: "someUserID"
        )

        XCTAssertEqual(testee.scope.predicate.predicateFormat, """
        canvasContextID == "course_someCourseID" \
        AND id != nil \
        AND userID == "someUserID"
        """)
    }
}
