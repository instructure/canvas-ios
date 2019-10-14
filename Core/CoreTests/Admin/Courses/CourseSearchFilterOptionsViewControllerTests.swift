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

import Foundation
import XCTest
@testable import Core

@available(iOS 13, *)
class CourseSearchFilterOptionsViewControllerTests: CoreTestCase {
    class Delegate: CourseSearchFilterOptionsDelegate {
        var filter: CourseSearchFilter?
        func courseSearchFilterOptions(_ filterOptions: CourseSearchFilterOptionsViewController, didChangeFilter filter: CourseSearchFilter) {
            self.filter = filter
        }
    }

    var nav: UINavigationController!
    var viewController: CourseSearchFilterOptionsViewController!
    var root: UIViewController?
    var listener = Delegate()

    var withoutStudentsCell: RightDetailTableViewCell {
        return try! XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RightDetailTableViewCell)
    }

    var termCell: RightDetailTableViewCell {
        return try! XCTUnwrap(viewController.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RightDetailTableViewCell)
    }

    override func setUp() {
        super.setUp()
        root = UIApplication.shared.keyWindow?.rootViewController
        viewController = CourseSearchFilterOptionsViewController()
        viewController.delegate = delegate
        nav = UINavigationController(rootViewController: viewController)
        UIApplication.shared.keyWindow!.rootViewController = nav
    }

    override func tearDown() {
        drainMainQueue()
        nav.viewControllers = []
        UIApplication.shared.keyWindow?.rootViewController = root
    }

    func load() {
        XCTAssertNotNil(viewController.view)
        drainMainQueue()
    }

    func testViewDidLoad() {
        load()
        XCTAssertEqual(viewController.title, "Filter")
        XCTAssertEqual(viewController.tableView.delegate as? CourseSearchFilterOptionsViewController, viewController)
        XCTAssertEqual(withoutStudentsCell.textLabel?.text, "Hide courses without students")
        XCTAssertEqual(withoutStudentsCell.accessoryType, .none)
        XCTAssertEqual(termCell.textLabel?.text, "Show courses from")
        XCTAssertEqual(termCell.detailTextLabel?.text, "All Terms")
        XCTAssertEqual(termCell.accessoryType, .disclosureIndicator)
    }

    func testReset() throws {
        viewController.filter = CourseSearchFilter(hideCoursesWithoutStudents: true, term: .make(name: "Filter Term"))
        load()
        let resetButton = try XCTUnwrap(viewController.navigationItem.rightBarButtonItem)
        XCTAssertEqual(resetButton.title, "Reset")
        XCTAssertEqual(
            resetButton.target as? CourseSearchFilterOptionsViewController,
            viewController
        )
        XCTAssertEqual(resetButton.action, #selector(CourseSearchFilterOptionsViewController.resetButtonPressed))
        viewController.resetButtonPressed()
        drainMainQueue()
        XCTAssertEqual(withoutStudentsCell.accessoryType, .none)
        XCTAssertEqual(termCell.detailTextLabel?.text, "All Terms")
    }

    func testSelectHideCoursesWithoutStudents() {
        load()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(withoutStudentsCell.accessoryType, .checkmark)
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(withoutStudentsCell.accessoryType, .none)
    }

    func testSelectTerm() throws {
        let active = APITerm.make(name: "Active Term", workflow_state: .active)
        let past = APITerm.make(name: "Past Term", end_at: .distantPast)
        viewController.terms = [active, past]
        load()
        viewController.tableView(viewController.tableView, didSelectRowAt: IndexPath(row: 0, section: 1))
        XCTAssertEqual(nav.viewControllers.count, 2)
        let picker = try XCTUnwrap(nav.viewControllers.last as? ItemPickerViewController)
        XCTAssertEqual(picker.delegate as? CourseSearchFilterOptionsViewController, viewController)
        XCTAssertEqual(picker.selected, IndexPath(row: 0, section: 0))
        XCTAssertEqual(picker.sections.count, 3)
        XCTAssertEqual(picker.sections[0].items.count, 1)
        XCTAssertEqual(picker.sections[0].title, nil)
        XCTAssertEqual(picker.sections[0].items[0].title, "All Terms")
        XCTAssertEqual(picker.sections[1].items.count, 1)
        XCTAssertEqual(picker.sections[1].title, "Active")
        XCTAssertEqual(picker.sections[1].items[0].title, "Active Term")
        XCTAssertEqual(picker.sections[2].items.count, 1)
        XCTAssertEqual(picker.sections[2].title, "Past")
        XCTAssertEqual(picker.sections[2].items[0].title, "Past Term")
    }

    func testItemPickerDidSelectRowAllTerms() {
        viewController.filter = CourseSearchFilter(term: APITerm.make())
        load()
        let picker = ItemPickerViewController.create(title: "", sections: [], selected: nil, delegate: nil)
        viewController.itemPicker(picker, didSelectRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNil(viewController.filter.term)
        XCTAssertEqual(termCell.detailTextLabel?.text, "All Terms")
    }

    func testItemPickerDidSelectRowActiveTerm() {
        let term = APITerm.make(name: "Active Term", workflow_state: .active)
        viewController.terms = [term]
        load()
        let picker = ItemPickerViewController.create(title: "", sections: [], selected: nil, delegate: nil)
        viewController.itemPicker(picker, didSelectRowAt: IndexPath(row: 0, section: 1))
        XCTAssertEqual(viewController.filter.term, term)
        XCTAssertEqual(termCell.detailTextLabel?.text, "Active Term")
    }

    func testItemPickerDidSelectRowPastTerm() {
        let term = APITerm.make(name: "Past Term", end_at: .distantPast, workflow_state: nil)
        viewController.terms = [term]
        load()
        let picker = ItemPickerViewController.create(title: "", sections: [], selected: nil, delegate: nil)
        viewController.itemPicker(picker, didSelectRowAt: IndexPath(row: 0, section: 2))
        XCTAssertEqual(termCell.detailTextLabel?.text, "Past Term")
        XCTAssertEqual(viewController.filter.term, term)
    }

    func testViewWillDisappear() {
        let filter = CourseSearchFilter(hideCoursesWithoutStudents: true, term: .make())
        load()
        viewController.filter = filter
        viewController.viewWillDisappear(false)
        XCTAssertEqual(listener.filter, filter)
    }
}
