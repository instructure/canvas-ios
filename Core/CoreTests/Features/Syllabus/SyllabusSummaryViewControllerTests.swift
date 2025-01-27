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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class SyllabusSummaryViewControllerTests: CoreTestCase {
    let courseID = "1"
    lazy var controller = SyllabusSummaryViewController.create(courseID: courseID)

    func testLayout() {
        let date = DateComponents(calendar: .current, timeZone: .current, year: 2020, month: 2, day: 12).date!
        let assignment = APICalendarEvent.make(
            id: "1",
            html_url: URL(string: "https://canvas.instructure.com/assignments/1")!,
            title: "assignment",
            start_at: date,
            type: .assignment,
            context_code: "course_\(courseID)"
        )
        let event = APICalendarEvent.make(
            id: "2",
            title: "event",
            start_at: date.inCalendar.addDays(1),
            type: .event,
            context_code: "course_\(courseID)"
        )
        let hiddenEvent = APICalendarEvent.make(
            id: "3",
            title: "event",
            start_at: date.inCalendar.addDays(1),
            type: .event,
            context_code: "course_\(courseID)",
            hidden: true
        )
        let nilDate = APICalendarEvent.make(
            id: "4",
            title: "nil date",
            start_at: nil,
            type: .assignment,
            context_code: "course_\(courseID)"
        )
        api.mock(controller.assignments, value: [assignment, nilDate])
        api.mock(controller.events, value: [event, hiddenEvent])
        api.mock(controller.course, value: .make(id: ID(courseID)))

        controller.view.layoutIfNeeded()
        let tableView = controller.tableView!

        waitUntil(1, shouldFail: true) {
            controller.tableView.dataSource?.tableView(tableView, numberOfRowsInSection: 0) == 3
        }

        let assignmentCell = cell(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(assignmentCell.itemNameLabel.text, "assignment")
        XCTAssertEqual(assignmentCell.iconImageView?.image, .assignmentLine)
        XCTAssertEqual(assignmentCell.dateLabel.text, date.dateTimeString)

        let eventCell = cell(at: IndexPath(row: 1, section: 0))
        XCTAssertEqual(eventCell.itemNameLabel.text, "event")
        XCTAssertEqual(eventCell.iconImageView?.image, .calendarMonthLine)
        XCTAssertEqual(eventCell.dateLabel.text, date.inCalendar.addDays(1).dateTimeString)

        let nilDateCell = cell(at: IndexPath(row: 2, section: 0))
        XCTAssertEqual(nilDateCell.itemNameLabel.text, "nil date")
        XCTAssertEqual(nilDateCell.iconImageView?.image, .assignmentLine)
        XCTAssertEqual(nilDateCell.dateLabel.text, "No Due Date")

        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(router.lastRoutedTo(assignment.html_url))
    }
}

extension SyllabusSummaryViewControllerTests {
    func cell(at indexPath: IndexPath) -> SyllabusSummaryItemCell {
        let tableView = controller.tableView!
        return tableView.dataSource?.tableView(tableView, cellForRowAt: indexPath) as! SyllabusSummaryItemCell
    }
}
