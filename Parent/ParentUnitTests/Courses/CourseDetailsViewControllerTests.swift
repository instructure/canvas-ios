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

    var isSyllabusShown: Bool {
        vc.viewControllers.contains { $0 is SyllabusViewController }
    }
    var isSummaryShown: Bool {
        vc.viewControllers.contains { $0 is SyllabusSummaryViewController }
    }

    override func setUp() {
        super.setUp()
        vc = CourseDetailsViewController.create(courseID: courseID, studentID: studentID)
        api.mock(GetFrontPageRequest(context: .course(courseID)), value: APIPage.make())
        api.mock(
            GetTabsRequest(context: .course(courseID)),
            value: [.make(id: "syllabus", html_url: URL(string: "/tabs")!)]
        )
    }

    func render() {
        vc.view.layoutIfNeeded()
        vc.viewWillAppear(false)
        vc.viewDidAppear(false)
    }

    func testInboxReplyButton() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make())
        api.mock(GetSearchRecipients(context: .course(courseID), userID: "1"), value: [.make()])

        render()

        XCTAssertNotNil(vc.replyButton)
        vc.replyButton?.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is CoreHostingController<ComposeMessageView>)
    }

    func testHomeIsFrontPage() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .wiki))
        render()
        XCTAssertFalse(isSyllabusShown)
    }

    func testHomeIsSyllabus() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .syllabus, syllabus_body: "body"))
        api.mock(vc.settings, value: .make())
        render()
        XCTAssertTrue(isSyllabusShown)
        XCTAssertTrue(isSummaryShown)
    }

    func testHomeIsNilSyllabus() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .syllabus, syllabus_body: nil))
        api.mock(vc.settings, value: .make())
        render()
        XCTAssertFalse(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsEmptySyllabus() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .syllabus, syllabus_body: ""))
        api.mock(vc.settings, value: .make())
        render()
        XCTAssertFalse(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsHiddenSyllabus() {
        api.mock(GetTabsRequest(context: .course(courseID)), value: [])
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .syllabus, syllabus_body: "body"))
        api.mock(vc.settings, value: .make(syllabus_course_summary: false))
        render()
        XCTAssertTrue(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsUnsupportedAndSyllabusPresentButNotInTabs() {
        api.mock(GetTabsRequest(context: .course(courseID)), value: [])
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .modules, syllabus_body: "body"))
        render()
        XCTAssertFalse(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsUnsupportedAndSyllabusIsEmpty() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .modules, syllabus_body: ""))
        render()
        XCTAssertFalse(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsUnsupportedAndSyllabusIsNil() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .modules, syllabus_body: nil))
        render()
        XCTAssertFalse(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }

    func testHomeIsUnsupportedAndSyllabusIsPresent() {
        api.mock(GetCourseRequest(courseID: courseID), value: .make(id: ID(courseID), default_view: .modules, syllabus_body: "body"))
        render()
        XCTAssertTrue(isSyllabusShown)
        XCTAssertFalse(isSummaryShown)
    }
}
