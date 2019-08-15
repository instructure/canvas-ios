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
import TestsFoundation
@testable import Core

class DiscussionEditTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return DiscussionEditTests.self }
    override var user: UITestUser? { return nil }

    let course1 = APICourse.make(id: "1", enrollments: [ .make(type: .teacher) ], permissions: .init(
        create_announcement: true,
        create_discussion_topic: true
    ))
    let noPermissionCourse = APICourse.make(id: "1", enrollments: [ .make(type: .teacher) ], permissions: .init(
        create_announcement: false,
        create_discussion_topic: false
    ))

    func testCantCreateDiscussion() {
        mockBaseRequests()
        mockData(GetCoursesRequest(), value: [ noPermissionCourse ])
        mockData(GetCourseRequest(courseID: "1"), value: noPermissionCourse)
        mockEncodableRequest("courses/1/discussion_topics?per_page=99&include[]=sections", value: [String]())

        logIn(domain: "canvas.instructure.com", token: "t")
        show("/courses/1/discussion_topics")
        app.find(label: "There are no discussions to display.").waitToExist()
        XCTAssertFalse(DiscussionList.newButton.isVisible)
    }

    func testCreateDiscussion() {
        mockBaseRequests()
        mockData(GetCoursesRequest(), value: [ course1 ])
        mockData(GetCourseRequest(courseID: "1"), value: course1)
        mockEncodableRequest("courses/1/discussion_topics?per_page=99&include[]=sections", value: [String]())
        mockEncodableRequest("courses/1/discussion_topics", value: [String: String](), error: "error")

        logIn(domain: "canvas.instructure.com", token: "t")
        show("/courses/1/discussion_topics")
        DiscussionList.newButton.tap()

        DiscussionEdit.titleField.waitToExist()
        XCTAssertFalse(DiscussionEdit.invalidLabel.isVisible)
        DiscussionEdit.doneButton.tap()
        DiscussionEdit.invalidLabel.waitToExist()
        DiscussionEdit.invalidTitleLabel.waitToExist()

        DiscussionEdit.titleField.typeText("Discuss This")
        XCUIElementWrapper(app.webViews.firstMatch).typeText("A new topic")
        DiscussionEdit.doneButton.tap()
    }
}
