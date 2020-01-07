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
@testable import Parent
import TestsFoundation

class CourseDetailsViewControllerTests: ParentTestCase {

    var vc: CourseDetailsViewController!
    let courseID = "1"
    let studentID = "1"

    override func setUp() {
        super.setUp()
        vc = CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
    }

    func testRender() {
        //  Most of the other features of this view controller are tested in the individual tabs

        ExperimentalFeature.parentInbox.isEnabled = true

        api.mock( GetCourseRequest(courseID: courseID), value: .make() )
        api.mock(GetFrontPageRequest(context: ContextModel(.course, id: courseID)), value: APIPage.make())

        vc.view.layoutIfNeeded()
        vc.viewDidLoad()
        vc.viewWillAppear(false)
        vc.viewDidAppear(false)

        XCTAssertNotNil(vc.replyButton)
        vc.replyButton?.sendActions(for: .primaryActionTriggered)

        XCTAssertTrue(router.lastRoutedTo(.compose()))
    }

    func testRenderWithExperimentalFeaturesOff() {
        ExperimentalFeature.parentInbox.isEnabled = false

        api.mock( GetCourseRequest(courseID: courseID), value: .make() )
        api.mock(GetFrontPageRequest(context: ContextModel(.course, id: courseID)), value: APIPage.make())

        vc.view.layoutIfNeeded()
        vc.viewDidLoad()
        vc.viewWillAppear(false)
        vc.viewDidAppear(false)

        XCTAssertNil(vc.replyButton)
    }
}
