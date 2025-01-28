//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

class PutDashboardCardPositionsTests: CoreTestCase {

    func testRequest() {
        // GIVEN
        let card1: DashboardCard = databaseClient.insert()
        card1.id = "1"
        card1.position = 1
        let card2: DashboardCard = databaseClient.insert()
        card2.id = "2"
        card2.position = 2

        // WHEN
        let testee = PutDashboardCardPositions(cards: [card2, card1])

        // THEN
        XCTAssertEqual(testee.request.method, .put)
        XCTAssertEqual(testee.request.path, "users/self/dashboard_positions")
        XCTAssertEqual(testee.request.body, .init(dashboard_positions: ["course_1": 1, "course_2": 2]))
    }

    func testUpdatesPositionsFromAPIResponse() {
        // GIVEN
        let card1: DashboardCard = databaseClient.insert()
        card1.id = "1"
        card1.position = 1
        let card2: DashboardCard = databaseClient.insert()
        card2.id = "2"
        card2.position = 2
        let card3: DashboardCard = databaseClient.insert()
        card3.id = "3"
        card3.position = 3
        let testee = PutDashboardCardPositions(cards: [])
        let apiResponse = APIDashboardCardPositions(dashboard_positions: ["course_1": 111, "course_2": 222])

        // WHEN
        testee.write(response: apiResponse,
                     urlResponse: nil,
                     to: databaseClient)

        // THEN
        let updatedCard1: DashboardCard = databaseClient.fetch(scope: .where(#keyPath(DashboardCard.id), equals: "1", ascending: true)).first!
        let updatedCard2: DashboardCard = databaseClient.fetch(scope: .where(#keyPath(DashboardCard.id), equals: "2", ascending: true)).first!
        let notUpdatedCard3: DashboardCard = databaseClient.fetch(scope: .where(#keyPath(DashboardCard.id), equals: "3", ascending: true)).first!
        XCTAssertEqual(updatedCard1.position, 111)
        XCTAssertEqual(updatedCard2.position, 222)
        XCTAssertEqual(notUpdatedCard3.position, 3)
    }
}
