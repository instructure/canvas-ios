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

class PlannerNoteDetailViewControllerTests: CoreTestCase {

    var p: Plannable!
    var vc: PlannerNoteDetailViewController!
    var date: Date = Clock.now

    override func setUp() {
        p = Plannable.make(from: .make(
            plannable_type: PlannableType.planner_note.rawValue,
            plannable: APIPlannable.plannable(
                details: "description", title: "title"),
            plannable_date: date),
                           in: databaseClient)
        vc = PlannerNoteDetailViewController.create(plannable: p)
    }

    func testLayout() {
        vc.loadView()
        vc.viewDidLoad()
        vc.viewDidAppear(false)

        XCTAssertEqual(vc.titleLabel.text, "title")
        XCTAssertEqual(vc.dateLabel.text, DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))
        XCTAssertEqual(vc.detailsLabel.text, "description")
    }
}
