//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class APIPlannableTests: XCTestCase {
    var req: GetPlannablesRequest!

    override func setUp() {
        super.setUp()
        req = GetPlannablesRequest()
    }

    func testPath() {
        XCTAssertEqual(req.path, "planner/items")
    }

    func testPathWithUserID() {
        req = GetPlannablesRequest(userID: "1", startDate: nil, endDate: nil, contextCodes: [], filter: "")
        XCTAssertEqual(req.path, "users/1/planner/items")
    }

	func testQuery() {
        let start = Date.now.inCalendar.addDays(-1)
        let end = Date.now.inCalendar.addDays(2)
        req = GetPlannablesRequest(startDate: start, endDate: end, contextCodes: ["course_1"], filter: "new_activity")
        let expected = [
            URLQueryItem(name: "per_page", value: "100"),
            URLQueryItem(name: "start_date", value: start.isoString()),
            URLQueryItem(name: "end_date", value: end.isoString()),
            URLQueryItem(name: "context_codes[]", value: "course_1"),
            URLQueryItem(name: "filter", value: "new_activity")
        ]
		XCTAssertEqual(req.queryItems, expected)
	}

	func testModel() {
		let model = APIPlannable.make()
		XCTAssertNotNil(model)

        let override = APIPlannerOverride.make()
        XCTAssertNotNil(override)
	}

    func testAPIPlannableContextWhenContextTypeAndIDIsSet() {
        let p = APIPlannable.make(course_id: "42", context_type: "Course", plannable_type: "assignment")
        XCTAssertEqual(p.context?.contextType, .course)
        XCTAssertEqual(p.context?.id, "42")
    }

    func testAPIPlannableContextWhenContextTypeAndOtherIDIsSet() {
        let p = APIPlannable.make(course_id: nil, user_id: "42", context_type: "Course", plannable_type: "assignment")
        XCTAssertEqual(p.context, nil)
    }

    func testAPIPlannableContextWhenContextTypeIsNil() {
        let p = APIPlannable.make(course_id: nil, context_type: nil, plannable_type: "assignment")
        XCTAssertEqual(p.context, nil)
    }

    func testAPIPlannableContextWhenPlannableTypeIsNote() {
        var p = APIPlannable.make(
            context_type: nil,
            plannable_type: "planner_note",
            plannable: .init(course_id: "42")
        )
        XCTAssertEqual(p.context?.contextType, .course)
        XCTAssertEqual(p.context?.id, "42")

        p = APIPlannable.make(
            context_type: nil,
            plannable_type: "planner_note",
            plannable: .init(user_id: "42")
        )
        XCTAssertEqual(p.context?.contextType, .user)
        XCTAssertEqual(p.context?.id, "42")

        // course id should take precedence
        p = APIPlannable.make(
            context_type: nil,
            plannable_type: "planner_note",
            plannable: .init(course_id: "7", user_id: "42")
        )
        XCTAssertEqual(p.context?.contextType, .course)
        XCTAssertEqual(p.context?.id, "7")

        // context from type should take precedence
        p = APIPlannable.make(
            group_id: "7",
            context_type: "Group",
            plannable_type: "planner_note",
            plannable: .init(course_id: "42")
        )
        XCTAssertEqual(p.context?.contextType, .group)
        XCTAssertEqual(p.context?.id, "7")
    }
}

class UpdatePlannerOverrideRequestTests: XCTestCase {
    private let testee = UpdatePlannerOverrideRequest(overrideId: "testID", body: .init(marked_complete: true))

    func testRequestPath() {
        XCTAssertEqual(testee.path, "planner/overrides/testID")
    }

    func testMethod() {
        XCTAssertEqual(testee.method, .put)
    }

    func testBody() {
        XCTAssertNotNil(testee.body)
    }
}

class CreatePlannerOverrideRequestTests: XCTestCase {
    private let testee = CreatePlannerOverrideRequest(body: .init(plannable_type: "testType", plannable_id: "testID", marked_complete: false))

    func testRequestPath() {
        XCTAssertEqual(testee.path, "planner/overrides")
    }

    func testMethod() {
        XCTAssertEqual(testee.method, .post)
    }

    func testBody() {
        XCTAssertNotNil(testee.body)
    }
}
