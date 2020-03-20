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

class GetPlannablesTests: CoreTestCase {
    var start = Clock.now
    var end = Clock.now.addDays(1)
    lazy var useCase = GetPlannables(startDate: start, endDate: end)

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-plannables--\(start)-\(end)--")
    }

    func testScope() {
        let first = Plannable.make(from: .make(
            plannable_id: "1",
            plannable: APIPlannable.plannable(title: "a", details: ""),
            plannable_date: start
        ))
        let second = Plannable.make(from: .make(
            plannable_id: "2",
            plannable: APIPlannable.plannable(title: "b", details: ""),
            plannable_date: start
        ))
        let third = Plannable.make(from: .make(
            plannable_id: "3",
            plannable: APIPlannable.plannable(title: "c", details: ""),
            plannable_date: start.addMinutes(1)
        ))
        let other = Plannable.make(from: .make(
            plannable_id: "4",
            plannable: APIPlannable.plannable(title: "d", details: ""),
            plannable_date: end.addDays(1)
        ))
        XCTAssertTrue([first, second, third].allSatisfy(useCase.scope.predicate.evaluate(with:)))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: other))
        let plannables: [Plannable] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(plannables, [first, second, third])
    }

    func testScopeWithUserID() {
        let yes = Plannable.make(from: .make(plannable_id: "1"), userID: "1")
        Plannable.make(from: .make(plannable_id: "2"), userID: nil)
        Plannable.make(from: .make(plannable_id: "3"), userID: "2")
        useCase = GetPlannables(userID: "1", startDate: start, endDate: end)
        let plannables: [Plannable] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(plannables, [yes])
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.startDate, start)
    }
}
