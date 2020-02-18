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
import WebKit

class PlannerListViewControllerTests: CoreTestCase {

    var vc: PlannerListViewController!
    let studentID = "1"

    override func setUp() {
        super.setUp()
        environment.mockStore = false
        vc = PlannerListViewController.create(studentID: studentID)
        vc.loadView()
    }

    func testLayout() {
        let date = Clock.now
        api.mock(GetPlannables(userID: studentID, startDate: Clock.now.startOfDay(), endDate: Clock.now.endOfDay()), value: [APIPlannable.make(plannable_date: date)])
        vc.viewDidLoad()
        vc.updateListForDates(start: Clock.now.startOfDay(), end: Clock.now.endOfDay())

        vc.emptyStateViewContainer.isHidden = true
        let cell = vc.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PlannerListCell
        XCTAssertEqual(cell?.title.text, "assignment a")
        XCTAssertEqual(cell?.courseCode.text, "Assignment Grades")
        XCTAssertEqual(cell?.dueDate.text, DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short) )
        XCTAssertEqual(cell?.points.text, nil)
    }

    func testEmptyState() {
        api.mock(GetPlannables(userID: studentID, startDate: Clock.now.startOfDay(), endDate: Clock.now.endOfDay()), value: [])
        vc.viewDidLoad()
        vc.updateListForDates(start: Clock.now.startOfDay(), end: Clock.now.endOfDay())

        vc.emptyStateViewContainer.isHidden = false
        XCTAssertEqual(vc.emptyStateHeader.text, "No Assignments")
        XCTAssertEqual(vc.emptyStateSubHeader.text, "It looks like assignments haven’t been created in this space yet.")
    }
}
