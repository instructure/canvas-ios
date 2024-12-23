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

@testable import Core
import XCTest

class GetGradingPeriodsTests: CoreTestCase {

    var useCase: GetGradingPeriods!
    let courseID: String = "1"

    override func setUp() {
        super.setUp()
        useCase = GetGradingPeriods(courseID: courseID)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-gradingPeriods-\(courseID)")

    }

    func testScope() {
        XCTAssertEqual(useCase.scope, Scope.where(#keyPath(GradingPeriod.courseID), equals: courseID, orderBy: #keyPath(GradingPeriod.startDate)))
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.courseID, courseID)
    }

    func testWrite() {
        let a = APIGradingPeriod.make(id: "1", title: "1")
        let b = APIGradingPeriod.make(id: "2", title: "2")

        useCase.write(response: [a, b], urlResponse: nil, to: databaseClient)
        let sort = NSSortDescriptor(key: (\GradingPeriod.id).string, ascending: true)
        let gradingPeriods: [GradingPeriod] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: [sort])

        XCTAssertEqual(gradingPeriods.count, 2)
        XCTAssertEqual(gradingPeriods.first?.id, "1")
        XCTAssertEqual(gradingPeriods.last?.id, "2")
    }

    func testModel() {
        let model = GradingPeriod.make(courseID: "1")
        XCTAssertNotNil(model)
    }

    func testCurrentGradingPeriod() {
        let a = GradingPeriod.make(from: .make(id: "1", title: "a", start_date: Clock.now.inCalendar.addDays(-3), end_date: Clock.now.inCalendar.addDays(3)))

        let b = GradingPeriod.make(from: .make(id: "2", title: "b", start_date: Clock.now.inCalendar.addDays(-100), end_date: Clock.now.inCalendar.addDays(-70)))

        let arr = [a, b]
        XCTAssertEqual(arr.current, a)
    }
}
