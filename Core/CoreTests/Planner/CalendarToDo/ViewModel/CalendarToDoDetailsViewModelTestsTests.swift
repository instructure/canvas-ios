//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

class CalendarToDoDetailsViewModelTests: CoreTestCase {

    func testProperties() {
        let todoDate = Date().addMonths(3)
        let apiPlannable = APIPlannable.make(
            plannable: .init(
                details: "TestDetails",
                title: "TestTitle"
            ),
            plannable_date: todoDate
        )
        let plannable = Plannable.make(from: apiPlannable,
                                       in: databaseClient)

        // WHEN
        let testee = CalendarToDoDetailsViewModel(plannable: plannable, interactor: CalendarToDoInteractorPreview())

        // THEN
        XCTAssertEqual(testee.navigationTitle, "To Do")
        XCTAssertEqual(testee.title, "TestTitle")
        XCTAssertEqual(testee.description, "TestDetails")
        XCTAssertEqual(testee.date, todoDate.dateTimeString)
    }
}
