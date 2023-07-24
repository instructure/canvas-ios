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
    let context = Context(.course, id: "1")
    var controller: AttendanceViewController!
    var navigation: UINavigationController!

    override func setUp() {
        super.setUp()

        let now = DateComponents(calendar: .current, timeZone: .current, year: 2019, month: 10, day: 31).date!
        Clock.mockNow(now)

        controller = AttendanceViewController(context: context, toolID: "1")
        controller.session.state = .active(API())

        navigation = UINavigationController(rootViewController: controller)

        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            context.canvasContextID: "#008EE2", // electric
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

    func cellAt(_ index: IndexPath) -> StatusCell {
        return controller.tableView.cellForRow(at: index) as! StatusCell
    }

    func testStatusDisplay() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.navigationController?.navigationBar.barTintColor!.hexString, UIColor(hexString: "#008EE2")!.ensureContrast(against: .backgroundLightest).hexString)
        XCTAssertEqual(controller.view.backgroundColor, .backgroundLightest)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, true)
        RunLoop.main.run(until: Date() + 1)
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, false)

        // Assert state from mock data
        let first = IndexPath(row: 0, section: 0)
        let second = IndexPath(row: 1, section: 0)
        XCTAssertEqual(controller.tableView(controller.tableView, numberOfRowsInSection: 0), 2)
        XCTAssertEqual(cellAt(first).accessibilityLabel, "Bob — Present")
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark Remaining as Present")

        // Mark all as present
        controller.markAllButton.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(cellAt(first).accessibilityLabel, "Bob — Present")
        XCTAssertEqual(cellAt(second).accessibilityLabel, "Sally — Present")
        XCTAssertGreaterThan(controller.markAllButtonBottom.constant, 0)

        // Use swipe action to unmark row 1
        let swipes = controller.tableView(controller.tableView, trailingSwipeActionsConfigurationForRowAt: first)?.actions
        XCTAssertEqual(swipes?.count, 3)
        swipes?.last?.handler(swipes!.last!, UIView()) { success in XCTAssertTrue(success) }
        XCTAssertEqual(cellAt(first).accessibilityLabel, "Bob")
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark Remaining as Present")

        // Use taps to mark row 2
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(cellAt(second).accessibilityLabel, "Sally — Absent")
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(cellAt(second).accessibilityLabel, "Sally — Late")
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(cellAt(second).accessibilityLabel, "Sally")
        XCTAssertEqual(controller.markAllButton.title(for: .normal), "Mark All as Present")
        controller.tableView(controller.tableView, didSelectRowAt: second)
        XCTAssertEqual(cellAt(second).accessibilityLabel, "Sally — Present")
    }

    func testSessionStartError() {
        controller.view.layoutIfNeeded()
        controller.session.state = .error(NSError.instructureError("doh"))
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "doh")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, true)
        waitUntil(shouldFail: true) {
            controller.tableView.refreshControl?.isRefreshing == false
        }
    }

    func testCourseError() {
        controller.view.layoutIfNeeded()
        api.mock(GetCourseRequest(courseID: context.id), error: NSError.instructureError("oops"))
        controller.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "oops")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, true)
        RunLoop.main.run(until: Date() + 1)
        waitUntil(shouldFail: true) {
            controller.tableView.refreshControl?.isRefreshing == false
        }
    }

    func testSectionsError() {
        controller.view.layoutIfNeeded()
        api.mock(GetCourseSectionsRequest(courseID: context.id, perPage: 100), error: NSError.instructureError("ded"))
        controller.tableView.refreshControl?.sendActions(for: .valueChanged)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "ded")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, true)
        waitUntil(shouldFail: true) {
            controller.tableView.refreshControl?.isRefreshing == false
        }
    }

    func testStatusesError() {
        let url = URL(string: "/statuses?section_id=1&class_date=2019-10-31", relativeTo: controller.session.baseURL)!
        api.mock(URLRequest(url: url), data: nil)
        controller.view.layoutIfNeeded()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Error: No data returned from the rollcall api.")
        XCTAssertEqual(controller.tableView.refreshControl?.isRefreshing, true)
        waitUntil(shouldFail: true) {
            controller.tableView.refreshControl?.isRefreshing == false
        }
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
