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

import UIKit
import XCTest
@testable import Core
@testable import Teacher

class TeacherSyllabusTabViewControllerTests: TeacherTestCase {
    lazy var controller = TeacherSyllabusTabViewController.create(context: .course("1"), courseID: "1")

    func testEditNotAvailableWithoutPermission() {
        api.mock(controller.permissions, value: .make(manage_content: false, manage_course_content_edit: false))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertNil(controller.navigationItem.rightBarButtonItem)
    }

    func testEditAvailableForManageContentPermission() {
        api.mock(controller.permissions, value: .make(manage_content: true, manage_course_content_edit: false))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.title, "Edit")
    }

    func testEditAvailableForManageCourseContentPermission() {
        api.mock(controller.permissions, value: .make(manage_content: false, manage_course_content_edit: true))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.navigationItem.rightBarButtonItem?.title, "Edit")
    }

    func testEditButton() {
        api.mock(controller.permissions, value: .make(manage_content: true))
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        _ = controller.editButton.target?.perform(controller.editButton.action)
        XCTAssert(router.lastRoutedTo(.parse("courses/1/syllabus/edit")))
    }
}
