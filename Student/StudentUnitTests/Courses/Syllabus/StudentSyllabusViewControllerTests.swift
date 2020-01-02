//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import UIKit
import XCTest
import Core
@testable import Student
@testable import Core
@testable import TestsFoundation

class StudentSyllabusViewControllerTests: StudentTestCase {

    var vc: StudentSyllabusViewController!
    var courseID: String = "1"

    override func setUp() {
        super.setUp()
        vc = StudentSyllabusViewController.create(courseID: courseID)
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRender() {
        //  given
        env.mockStore = false
        api.mock(vc.presenter.courses, value: APICourse.make())
        api.mock(vc.presenter.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
        ]))

        let assignments = GetSyllabusAssignments(courseID: courseID, sort: .dueAt)
        api.mock(assignments, value: [APIAssignment.make()])

        let calendarEvents = GetCalendarEvents(context: ContextModel(.course, id: courseID))
        api.mock(calendarEvents, value: [APICalendarEvent.make()])

        //  when
        loadView()
        vc.viewDidLoad()

        //  then
        let titleView = vc.navigationItem.titleView as? TitleSubtitleView
        XCTAssertEqual(titleView?.title, "Course Syllabus")

        var cell: HorizontalMenuViewController.MenuCell? = vc.collectionView(vc.menu!, cellForItemAt: IndexPath(item: 0, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Syllabus")

        cell = vc.collectionView(vc.menu!, cellForItemAt: IndexPath(item: 1, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Summary")
    }
}

class SyllabusActionableItemsViewControllerTests: StudentTestCase {

    var vc: SyllabusActionableItemsViewController!
    var courseID: String = "1"

    override func setUp() {
        super.setUp()
        vc = SyllabusActionableItemsViewController(courseID: courseID, sort: GetAssignments.Sort.dueAt)
    }

    func loadView() {
        vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 800)
        vc.view.layoutIfNeeded()
    }

    func testRender() {
        //  given
        env.mockStore = false
        api.mock(vc.presenter!.course, value: APICourse.make())
        api.mock(vc.presenter!.color, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
        ]))

        let assignments = GetSyllabusAssignments(courseID: courseID, sort: .dueAt)
        api.mock(assignments, value: [APIAssignment.make()])

        let calendarEvents = GetCalendarEvents(context: ContextModel(.course, id: courseID))
        let calEvent = APICalendarEvent.make()
        api.mock(calendarEvents, value: [calEvent])

        //  when
        loadView()
        vc.viewDidLoad()

        //  then
        var cell: SyllabusActionableItemsCell? = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? SyllabusActionableItemsCell
        let expectedDate = DateFormatter.localizedString(from: calEvent.start_at!, dateStyle: .medium, timeStyle: .short)
        XCTAssertEqual(cell?.dateLabel?.text, expectedDate)
        XCTAssertEqual(cell?.iconImageView?.image, UIImage.icon(.calendarMonth, .line))

        cell = vc.tableView(vc.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? SyllabusActionableItemsCell
        XCTAssertEqual(cell?.itemNameLabel?.text, "some assignment")
        XCTAssertEqual(cell?.dateLabel?.text, "No Due Date")
        XCTAssertEqual(cell?.iconImageView?.image, UIImage.icon(.assignment, .line))
        XCTAssertEqual(cell?.iconImageView?.tintColor, UIColor(hexString: "#f00"))

        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("calendar_events/1")))

        vc.tableView(vc.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssert(router.lastRoutedTo(.parse("https://canvas.instructure.com/courses/1/assignments/1")))
    }
}
