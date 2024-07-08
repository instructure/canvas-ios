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
@testable import Core
@testable import TestsFoundation

class SyllabusTabViewControllerTests: CoreTestCase {
    lazy var controller = SyllabusTabViewController.create(courseID: "1")

    func testLayout() {
        api.mock(controller.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00"
        ]))
        api.mock(controller.course, value: .make(syllabus_body: "not empty"))
        api.mock(controller.settings, value: .make())

        let nav = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(nav.navigationBar.barTintColor?.hexString, "#ed0000")
        let titleView = controller.navigationItem.titleView as? TitleSubtitleView
        XCTAssertEqual(titleView?.title, "Course Syllabus")
        XCTAssertEqual(titleView?.subtitle, "Course One")

        var cell = controller.collectionView(controller.menu!, cellForItemAt: IndexPath(item: 0, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Syllabus")
        cell = controller.collectionView(controller.menu!, cellForItemAt: IndexPath(item: 1, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Summary")
    }

    func testNoSyllabus() {
        api.mock(controller.course, value: .make())
        api.mock(controller.settings, value: .make())
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.menu?.numberOfItems(inSection: 0), 1)
        let cell = controller.collectionView(controller.menu!, cellForItemAt: IndexPath(item: 0, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Summary")
    }

    func testNoSummary() {
        api.mock(controller.course, value: .make(syllabus_body: "not empty"))
        api.mock(controller.settings, value: .make(syllabus_course_summary: false))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.menu?.numberOfItems(inSection: 0), 1)
        let cell = controller.collectionView(controller.menu!, cellForItemAt: IndexPath(item: 0, section: 0)) as? HorizontalMenuViewController.MenuCell
        XCTAssertEqual(cell?.title?.text, "Syllabus")
    }

    func testSummaryAppear() {
        api.mock(controller.course, value: .make(syllabus_body: "not empty"))
        api.mock(controller.settings, value: .make(syllabus_course_summary: false))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)

        XCTAssertEqual(controller.menu?.numberOfItems(inSection: 0), 1)
        api.mock(controller.settings, value: .make(syllabus_course_summary: true))
        controller.settings.refresh(force: true)
        XCTAssertEqual(controller.menu?.numberOfItems(inSection: 0), 2)
    }
}
