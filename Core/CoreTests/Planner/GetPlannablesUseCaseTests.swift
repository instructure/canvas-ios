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

class GetPlannablesUseCaseTests: CoreTestCase {

    var useCase: GetPlannables!

    override func setUp() {
        super.setUp()
        useCase = GetPlannables(userID: nil)
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, nil)
    }

    func testScope() {
        XCTAssertEqual(useCase.scope, Scope.all(orderBy: #keyPath(Plannable.date)))
    }

    func testScopeWithUserID() {
        useCase = GetPlannables(userID: "1")
        let expected = Scope.where(#keyPath(Plannable.userID), equals: "1", orderBy: #keyPath(Plannable.date))
        XCTAssertEqual(useCase.scope, expected)
    }

    func testRequest() {
        XCTAssertEqual(useCase.request.startDate, nil)
    }
}
