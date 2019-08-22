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

    let course1 = APICourse.make(id: "1", enrollments: [ .make(type: "TeacherEnrollment") ], permissions: .init(
        create_announcement: true,
        create_discussion_topic: true
    ))
    let noPermissionCourse = APICourse.make(id: "1", enrollments: [ .make(type: "TeacherEnrollment") ], permissions: .init(
        create_announcement: false,
        create_discussion_topic: false
    ))

    func testCantCreateDiscussion() {
        mockBaseRequests()
        mockData(GetCoursesRequest(), value: [ noPermissionCourse ])
        mockData(GetCourseRequest(courseID: "1"), value: noPermissionCourse)
        mockEncodableRequest("courses/1/discussion_topics?per_page=99&include[]=sections", value: [String]())

        logIn()
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

        logIn()
        show("/courses/1/discussion_topics")
        DiscussionList.newButton.tap()

        DiscussionEdit.titleField.waitToExist()
        XCTAssertFalse(DiscussionEdit.invalidLabel.isVisible)
        XCTAssertFalse(DiscussionEdit.attachmentButton.isVisible)
        DiscussionEdit.doneButton.tap()
        DiscussionEdit.invalidLabel.waitToExist()
        DiscussionEdit.invalidTitleLabel.waitToExist()

        DiscussionEdit.titleField.typeText("Discuss This")
        XCUIElementWrapper(app.webViews.firstMatch).typeText("A new topic")
        DiscussionEdit.doneButton.tap()
    }

    func testCreateDiscussionWithAttachment() {
        mockBaseRequests()
        mockData(GetCoursesRequest(), value: [course1])
        mockData(GetCourseRequest(courseID: "1"), value: course1)
        mockEncodableRequest("courses/1/discussion_topics?per_page=99&include[]=sections", value: [String]())
        mockEncodableRequest("courses/1/discussion_topics", value: [String: String]())
        mockEncodableRequest("courses/1/settings", value: ["allow_student_forum_attachments": true])
        mockEncodableRequest("courses/1/features/enabled", value: [String: String]())

        let targetUrl = "https://canvas.s3.bucket.com/bucket/1"
        mockEncodableRequest("users/self/files", value: FileUploadTarget.make(upload_url: URL(string: targetUrl)!))
        mockEncodableRequest(targetUrl, value: ["id": "1"])
        mockEncodableRequest("files/1", value: APIFile.make())

        logIn()
        show("/courses/1/discussion_topics")
        DiscussionList.newButton.tap()
        DiscussionEdit.attachmentButton.tap()
        Attachments.addButton.tap()
        allowAccessToPhotos {
            app.find(label: "Choose From Library").tap()
        }
        app.find(label: "Camera Roll").tap()
        app.find(labelContaining: "Photo, ").tap()

        app.find(label: "Upload complete").waitToExist()
        let img = XCUIElementWrapper(app.images.firstMatch)
        XCTAssertFalse(img.exists)
        app.find(label: "Upload complete").tap()
        img.waitToExist()
        app.find(id: "screen.dismiss").tap()
        app.find(id: "attachments.attachment-row.0.remove.btn").tap()
        app.find(label: "Remove").tap()

        app.find(label: "No Attachments").waitToExist()

        Attachments.addButton.tap()
        app.find(label: "Choose From Library").tap()
        app.find(label: "Camera Roll").tap()
        app.find(labelContaining: "Photo, ").tap()
        app.find(label: "Upload complete").waitToExist()

        Attachments.dismissButton.tap()

        XCTAssertEqual(DiscussionEdit.attachmentButton.waitToExist().label, "Edit attachment (1)")
    }
}
