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
import TestsFoundation

class AssignmentDatesViewControllerTests: CoreTestCase {
    lazy var controller = AssignmentDatesViewController.create(courseID: "1", assignmentID: "1")

    func getText() -> String {
        return controller.linesView.arrangedSubviews.compactMap { view in
            (view as? UILabel)?.attributedText?.string
        } .joined(separator: "\n")
    }

    func testMultipleDueDates() {
        api.mock(controller.assignment, value: .make(all_dates: [
            .make(),
            .make(id: "2", base: nil, title: "Section 2", due_at: Date()),
        ]))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(getText(), "Multiple Due Dates")
    }

    func testNoDueDates() {
        api.mock(controller.assignment, value: .make(due_at: nil))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(getText(), """
        Due: --
        For: -
        Available From: --
        Available Until: --
        """)
    }

    func testSingleDate() {
        api.mock(controller.assignment, value: .make(all_dates: [ .make(
            due_at: DateComponents(calendar: .current, year: 2020, month: 5, day: 20).date,
            unlock_at: DateComponents(calendar: .current, year: 2020, month: 5, day: 1).date,
            lock_at: DateComponents(calendar: .current, year: 2030, month: 6, day: 1).date
        ), ]))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(getText(), """
        Due: May 20, 2020 at 12:00 AM
        For: Everyone
        Available From: May 1, 2020 at 12:00 AM
        Available Until: Jun 1, 2030 at 12:00 AM
        """)
    }

    func testClosed() {
        api.mock(controller.assignment, value: .make(all_dates: [ .make(
            id: "3", base: nil, title: "Group",
            lock_at: DateComponents(calendar: .current, year: 2020, month: 1, day: 1).date
        ), ]))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(getText(), """
        Due: --
        For: Group
        Availability: Closed
        """)
    }

    func testButton() {
        api.mock(controller.assignment, value: .make())
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.button.accessibilityLabel, "View all dates")
        controller.button.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/assignments/1/due_dates")))
    }
}
