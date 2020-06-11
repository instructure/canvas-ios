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
        api.mock(vc.presenter.courses, value: APICourse.make())
        api.mock(vc.presenter.colors, value: APICustomColors(custom_colors: [
            "course_1": "#f00",
        ]))

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
