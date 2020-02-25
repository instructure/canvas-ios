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
        XCTAssertEqual(useCase.scope, Scope(predicate: NSPredicate(format: "%@ <= %K AND %K < %@",
            start as NSDate, #keyPath(Plannable.date),
            #keyPath(Plannable.date), end as NSDate
        ), orderBy: #keyPath(Plannable.date)))
    }

    func testScopeWithUserID() {
        useCase = GetPlannables(userID: "1", startDate: start, endDate: end)
        XCTAssertEqual(useCase.scope, Scope(predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(key: #keyPath(Plannable.userID), equals: "1"),
            NSPredicate(format: "%@ <= %K AND %K < %@",
                start as NSDate, #keyPath(Plannable.date),
                #keyPath(Plannable.date), end as NSDate
            ),
        ]), orderBy: #keyPath(Plannable.date)))
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.startDate, start)
    }
}
