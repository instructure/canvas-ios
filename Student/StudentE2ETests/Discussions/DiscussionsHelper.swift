//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation
import Core
import TestsFoundation
import XCTest

public class DiscussionsHelper: BaseHelper {
    // MARK: Discussion UI elements and functions
    public static var discussionsNewButton: Element { app.find(id: "DiscussionList.newButton") }
    public static var noDiscussionsPandaImage: Element { app.find(id: "PandaNoDiscussions") }

    public static func discussionButton(discussion: DSDiscussionTopic) -> Element {
        app.find(id: "DiscussionListCell.\(discussion.id)")
    }

    public static func discussionDataLabel(discussion: DSDiscussionTopic, label: DiscussionLabelTypes) -> Element {
        discussionButton(discussion: discussion).rawElement.findAll(type: .staticText)[label.rawValue]
    }

    public static func discussionsNavBar(course: DSCourse) -> Element {
        app.find(id: "Discussions, \(course.name)")
    }

    // MARK: Discussion Detail UI elements and functions
    // Detail screen
    public static func discussionDetailsNavBar(course: DSCourse) -> Element {
        app.find(id: "Discussion Details, \(course.name)")
    }
    public static var discussionDetailsOptionsButton: Element { app.find(id: "DiscussionDetails.options") }
    public static var discussionDetailsTitleLabel: Element { app.find(id: "DiscussionDetails.title") }
    public static var discussionDetailsLastPostLabel: Element {
        app.find(id: "DiscussionDetails.body").rawElement.find(type: .staticText)
    }
    public static var discussionDetailsMessageLabel: Element {
        app.find(id: "DiscussionDetails.body").rawElement.findAll(type: .staticText)[1]
    }
    public static var discussionDetailsReplyButton: Element {
        app.find(id: "DiscussionDetails.body").rawElement.findAll(type: .link)[1]
    }
    public static var discussionDetailsRepliesSection: Element {
        app.find(id: "DiscussionDetails.body").rawElement.find(label: "Replies", type: .other)
    }
    public static var discussionDetailsFirstReplyLabel: Element {
        app.find(id: "DiscussionDetails.body").rawElement.findAll(type: .other)[6].rawElement.find(type: .staticText)
    }

    // Reply screen
    public static var discussionDetailsReplyNavBar: Element { app.find(id: "Reply") }
    public static var discussionDetailsReplyEditorTextField: Element {
        app.find(id: "RichContentEditor.webView").rawElement.find(type: .textView)
    }
    public static var discussionDetailsReplyEditorSendButton: Element {
        app.find(id: "DiscussionEditReply.sendButton")
    }
    public static var discussionDetailsReplyEditorAttachmentButton: Element {
        app.find(id: "DiscussionEditReply.attachmentButton")
    }

    // MARK: Other functions
    @discardableResult
    public static func createDiscussion(
        course: DSCourse,
        title: String = "Sample Discussion",
        message: String = "Message of ",
        isAnnouncement: Bool = false,
        published: Bool = true,
        isAssignment: Bool = false,
        dueDate: String? = nil) -> DSDiscussionTopic {
        let discussionAssignment = CreateDSAssignmentRequest.RequestDSAssignment(
            name: title, description: message + title, published: published, submission_types: [.online_text_entry], due_at: dueDate)
        let discussionBody = CreateDSDiscussionRequest.RequestDSDiscussion(
            title: title, message: message + title, is_announcement: isAnnouncement,
            published: published, assignment: discussionAssignment)
        return seeder.createDiscussion(courseId: course.id, requestBody: discussionBody)
    }

    public static func navigateToDiscussions(course: DSCourse) {
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.discussions.tap()
    }

    @discardableResult
    public static func replyToDiscussion(replyText: String = "Test replying to discussion") -> Bool {
        DiscussionsHelper.discussionDetailsReplyButton.tap()
        let discussionDetailsReplyEditorTextField = DiscussionsHelper.discussionDetailsReplyEditorTextField.waitToExist()
        discussionDetailsReplyEditorTextField.pasteText(replyText)
        discussionDetailsReplyEditorSendButton.tap()
        let discussionDetailsRepliesSection = DiscussionsHelper.discussionDetailsRepliesSection.waitToExist()
        return discussionDetailsRepliesSection.isVisible
    }
}

public enum DiscussionLabelTypes: Int {
    case lastPost = 0
    case replies = 1
    case unread = 3
}
