//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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
import TestsFoundation

class CourseSettingsViewModelTests: CoreTestCase {

    func testPropertiesPopulated() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        api.mock(GetCourse(courseID: "1"), value: .make())

        let testee = CourseSettingsViewModel(context: .course("1"))
        XCTAssertEqual(testee.state, .loading)
        testee.viewDidAppear()

        XCTAssertEqual(testee.state, .ready)
        XCTAssertEqual(testee.errorText, nil)
        XCTAssertEqual(testee.courseColor, .ash)
        XCTAssertEqual(testee.courseName, "Course One")
        XCTAssertEqual(testee.imageURL, nil)
        XCTAssertEqual(testee.hideColorOverlay, true)
    }

    func testHomeSelector() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        api.mock(GetCourse(courseID: "1"), value: .make(default_view: .syllabus))

        let testee = CourseSettingsViewModel(context: .course("1"))
        testee.viewDidAppear()
        testee.defaultViewSelectorTapped(router: router, viewController: WeakViewController(UIViewController()))

        guard let picker = router.last as? ItemPickerViewController else { XCTFail("No pickers were presented"); return }
        guard picker.sections.count == 1, let section = picker.sections.first else { XCTFail("Section count mismatch"); return }

        picker.view.layoutIfNeeded()
        XCTAssertNil(section.title)
        XCTAssertEqual(picker.selected, IndexPath(row: 3, section: 0))
        XCTAssertEqual(section.items, [
            ItemPickerItem(title: NSLocalizedString("Assignments List", comment: "")),
            ItemPickerItem(title: NSLocalizedString("Course Activity Stream", comment: "")),
            ItemPickerItem(title: NSLocalizedString("Course Modules", comment: "")),
            ItemPickerItem(title: NSLocalizedString("Syllabus", comment: "")),
            ItemPickerItem(title: NSLocalizedString("Pages Front Page", comment: "")),
        ])

        XCTAssertEqual(testee.newDefaultView, .syllabus)
        picker.tableView.delegate?.tableView?(picker.tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(testee.newDefaultView, .modules)
    }

    func testSave() {
        api.mock(GetUserSettings(userID: "self"), value: .make(hide_dashcard_color_overlays: true))
        api.mock(GetCourse(courseID: "1"), value: .make(default_view: .syllabus))

        let testee = CourseSettingsViewModel(context: .course("1"))
        testee.viewDidAppear()

        testee.newDefaultView = .assignments
        testee.newName = "New Course Name"

        api.mock(UpdateCourse(courseID: "1", name: "New Course Name", defaultView: .assignments), value: .make(), response: nil, error: nil)
        XCTAssertNil(router.dismissed)
        testee.doneTapped(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertNil(testee.errorText)
        XCTAssertNotNil(router.dismissed)
    }
}
