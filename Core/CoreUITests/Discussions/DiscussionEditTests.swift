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
        mockData(ListDiscussionTopicsRequest(context: .course(noPermissionCourse.id.value)), value: [])

        show("/courses/\(noPermissionCourse.id.value)/discussion_topics")
        app.find(label: "There are no discussions to display.").waitToExist()
        XCTAssertFalse(DiscussionList.newButton.isVisible)
    }

    func testCreateDiscussion() {
        mockBaseRequests()
        mockData(ListDiscussionTopicsRequest(context: .course(course1.id.value)), value: [])
        mockData(ListDiscussionTopicsRequest(context: .course(course1.id.value), perPage: nil, include: []), value: [])
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": false])

        show("/courses/\(course1.id)/discussion_topics")
        DiscussionList.newButton.tap()

        DiscussionEdit.titleField.waitToExist()
        XCTAssertFalse(DiscussionEdit.invalidLabel.isVisible)
        XCTAssertFalse(DiscussionEdit.attachmentButton.isVisible)
        DiscussionEdit.doneButton.tap()
        DiscussionEdit.invalidLabel.waitToExist()
        DiscussionEdit.invalidTitleLabel.waitToExist()

        DiscussionEdit.titleField.typeText("Discuss This")
        app.webViews.firstElement.typeText("A new topic")
        DiscussionEdit.doneButton.tap()
        DiscussionEdit.titleField.waitToVanish()
    }

    func testCreateDiscussionWithAttachment() {
        mockBaseRequests()
        mockData(ListDiscussionTopicsRequest(context: .course(course1.id.value)), value: [])
        mockData(ListDiscussionTopicsRequest(context: .course(course1.id.value), perPage: nil, include: []), value: [])
        mockEncodableRequest("courses/\(course1.id)/settings", value: ["allow_student_forum_attachments": true])
        mockEncodableRequest("conversations?include%5B%5D=participant_avatars&per_page=50", value: [String]())

        let targetUrl = "https://canvas.s3.bucket.com/bucket/1"
        mockEncodableRequest("users/self/files", value: FileUploadTarget.make(upload_url: URL(string: targetUrl)!))
        mockEncodableRequest(targetUrl, value: ["id": "1"])
        mockEncodableRequest("files/1", value: APIFile.make())

        show("/courses/\(course1.id)/discussion_topics")
        DiscussionList.newButton.waitToExist(10).tap()
        DiscussionEdit.attachmentButton.tap()
        Attachments.addButton.tap()
        allowAccessToPhotos {
            app.find(label: "Choose From Library").tap()
        }

        let photo = app.find(labelContaining: "Photo, ")
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()

        app.find(label: "Upload complete").waitToExist()
        let img = app.find(id: "AttachmentView.image")
        app.find(label: "Upload complete").tapUntil { img.exists == true }
        NavBar.dismissButton.tap()
        app.find(id: "attachments.attachment-row.0.remove.btn").tap()
        app.find(label: "Remove").tap()

        app.find(label: "No Attachments").waitToExist()

        Attachments.addButton.tap()
        app.find(label: "Choose From Library").tap()
        app.find(label: "All Photos").tapUntil { photo.exists }
        photo.tap()
        app.find(label: "Upload complete").waitToExist()

        Attachments.dismissButton.tap()

        XCTAssertEqual(DiscussionEdit.attachmentButton.label(), "Edit attachment (1)")

        DiscussionEdit.attachmentButton.tap()
    }
}
