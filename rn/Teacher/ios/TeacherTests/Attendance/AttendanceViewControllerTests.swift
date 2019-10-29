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

import XCTest
@testable import Core
@testable import Teacher
import TestsFoundation

class AttendanceViewControllerTests: TeacherTestCase {
    let context = ContextModel(.course, id: "1")
    var controller: AttendanceViewController!

    override func setUp() {
        super.setUp()

        let now = DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 10, day: 31).date!
        Clock.mockNow(now)

        controller = AttendanceViewController(context: context, toolID: "1")
        controller.session.state = .active(MockURLSession())

        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            context.canvasContextID: "#FFFF00", // yellow
        ]))
        api.mock(GetCourseRequest(courseID: context.id), value: .make())
        api.mock(GetCourseSectionsRequest(courseID: context.id, perPage: 100), value: [
            .make(),
            .make(name: "section 2"),
        ])
        let url = URL(string: "/statuses?section_id=1&class_date=2019-10-31", relativeTo: controller.session.baseURL)!
        api.mock(URLRequest(url: url), data: try? controller.session.encoder.encode([
            Status.make(attendance: .present),
            Status.make(id: "2", studentID: "2", student: .make(id: "2", name: "Sally")),
        ]))
        api.mock(URLRequest(url: URL(string: "/statuses", relativeTo: controller.session.baseURL)!), data: try? controller.session.encoder.encode(Status.make()))
        api.mock(URLRequest(url: URL(string: "/statuses/1", relativeTo: controller.session.baseURL)!), data: try? controller.session.encoder.encode(Status.make()))
        api.mock(URLRequest(url: URL(string: "/statuses/2", relativeTo: controller.session.baseURL)!), data: try? controller.session.encoder.encode(Status.make(id: "2")))
    }

    func testStatusDisplay() {
        controller.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .named(.backgroundLightest))
        XCTAssertEqual(controller.statuses.count, 2)
        XCTAssertEqual(controller.preferredStatusBarStyle, .lightContent)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)

        // Assert state from mock data
        let first = IndexPath(row: 0, section: 0)
        let second = IndexPath(row: 1, section: 0)
        XCTAssertEqual(controller.statuses[first.row].status.attendance, .present)
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark Remaining as Present")

        // Mark all as present
        controller.markAllButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(controller.statuses[first.row].status.attendance, .present)
        XCTAssertEqual(controller.statuses[first.row].status.attendance, .present)
        XCTAssertGreaterThan(controller.markAllButtonBottom.constant, 0)

        // Use swipe action to unmark row 1
        let swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: first)?.actions
        XCTAssertEqual(swipes?.count, 3)
        swipes?.last?.handler(swipes!.last!, UIView()) { success in XCTAssertTrue(success) }
        XCTAssertNil(controller.statuses[first.row].status.attendance)
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark Remaining as Present")

        // Use taps to mark row 2
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(controller.statuses[second.row].status.attendance, .absent)
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(controller.statuses[second.row].status.attendance, .late)
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertNil(controller.statuses[second.row].status.attendance)
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark All as Present")
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(controller.statuses[second.row].status.attendance, .present)
    }

    func testSessionStartError() {
        controller.view.layoutIfNeeded()
        controller.session.state = .error(NSError.instructureError("doh"))
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "doh")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
    }

    func testCourseError() {
        controller.view.layoutIfNeeded()
        api.mock(GetCourseRequest(courseID: context.id), error: NSError.instructureError("oops"))
        controller.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "oops")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
    }

    func testSectionsError() {
        controller.view.layoutIfNeeded()
        api.mock(GetCourseSectionsRequest(courseID: context.id, perPage: 100), error: NSError.instructureError("ded"))
        controller.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "ded")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
    }

    func testStatusesError() {
        let url = URL(string: "/statuses?section_id=1&class_date=2019-10-31", relativeTo: controller.session.baseURL)!
        api.mock(URLRequest(url: url), data: nil)
        controller.view.layoutIfNeeded()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Error: No data returned from the rollcall api.")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)
    }

    func testChangeDate() {
        controller.view.layoutIfNeeded()
        let dateButton = controller.navigationItem.rightBarButtonItem?.customView as? UIButton
        dateButton?.sendActions(for: .primaryActionTriggered)

        let picker = (router.presented as? UINavigationController)?.viewControllers[0] as? DatePickerViewController
        picker?.delegate?.didSelectDate(Clock.now.add(.minute, number: 1))
        XCTAssertEqual(controller.date, Clock.now.add(.minute, number: 1))
    }

    func testChangeSection() {
        controller.view.layoutIfNeeded()
        controller.changeSectionButton.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is UIAlertController)
    }
}
