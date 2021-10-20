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

class DiscussionEditorTests: CoreUITestCase {
    lazy var course1 = mock(course: .make(id: "1", enrollments: [ .make(type: "TeacherEnrollment") ], permissions: .init(
        create_announcement: true,
        create_discussion_topic: true
    )))
    lazy var noPermissionCourse = mock(course: .make(id: "1", enrollments: [ .make(type: "TeacherEnrollment") ], permissions: .init(
        create_announcement: false,
        create_discussion_topic: false
    )))

    func testCantCreateDiscussion() {
        mockBaseRequests()
        mockData(GetDiscussionTopicsRequest(context: .course(noPermissionCourse.id.value)), value: [])

        show("/courses/\(noPermissionCourse.id.value)/discussion_topics")
        app.find(label: "It looks like discussions haven’t been created in this space yet.").waitToExist()
        XCTAssertFalse(DiscussionList.newButton.isVisible)
    }

    func testCreateDiscussion() {
        mockBaseRequests()
        mockData(GetDiscussionTopicsRequest(context: .course(course1.id.value)), value: [])
        mockData(GetDiscussionTopicsRequest(context: .course(course1.id.value), perPage: nil, include: []), value: [])
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": false])

        show("/courses/\(course1.id)/discussion_topics")
        DiscussionList.newButton.tap()

        DiscussionEditor.titleField.typeText("Discuss This")
        app.webViews.firstElement.typeText("A new topic")

        mockData(PostDiscussionTopicRequest(context: .course(course1.id.value)), value: .make())
        DiscussionEditor.doneButton.tap()
        DiscussionEditor.titleField.waitToVanish()
    }

    func testCreateDiscussionWithAttachment() {
        // Disabled test, Photo library picker doesn't work on bitrise simulator. To re-enable it, right click on the test symbol and select enabled or edit NightlyTests.xctestplan
        mockBaseRequests()
        mockData(GetDiscussionTopicsRequest(context: .course(course1.id.value)), value: [])
        mockData(GetDiscussionTopicsRequest(context: .course(course1.id.value), perPage: nil, include: []), value: [])
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": true])
        mockEncodableRequest("conversations?include%5B%5D=participant_avatars&per_page=50", value: [String]())

        show("/courses/\(course1.id)/discussion_topics")
        DiscussionList.newButton.tapUntil {
            DiscussionEditor.attachmentButton.exists
        }
        XCTAssertEqual(DiscussionEditor.attachmentButton.label(), "Add Attachment")
        DiscussionEditor.attachmentButton.tap()
        allowAccessToPhotos {
            app.find(label: "Photo Library").tap()
        }

        app.find(labelContaining: "Photo, ").tap()
        app.find(label: "Remove Attachment").waitToExist()
    }

    func testCreateEmptyAnnouncement() {
        mockBaseRequests()

        show("/courses/\(course1.id)/announcements/new")

        DiscussionEditor.doneButton.tap()
        app.find(label: "A description is required").waitToExist()
    }
}
