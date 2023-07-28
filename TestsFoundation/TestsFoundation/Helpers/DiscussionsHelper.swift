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

public class DiscussionsHelper: BaseHelper {
    public static var newButton: XCUIElement { app.find(id: "DiscussionList.newButton") }
    public static var noDiscussionsPandaImage: XCUIElement { app.find(id: "PandaNoDiscussions") }

    public static func discussionButton(discussion: DSDiscussionTopic) -> XCUIElement {
        app.find(id: "DiscussionListCell.\(discussion.id)")
    }

    public static func discussionDataLabel(discussion: DSDiscussionTopic, label: DiscussionLabelTypes) -> XCUIElement {
        discussionButton(discussion: discussion).findAll(type: .staticText)[label.rawValue]
    }

    public static func discussionsNavBar(course: DSCourse) -> XCUIElement {
        app.find(id: "Discussions, \(course.name)")
    }

    public struct Details {
        public static func navBar(course: DSCourse) -> XCUIElement {
            app.find(id: "Discussion Details, \(course.name)")
        }
        public static var optionsButton: XCUIElement { app.find(id: "DiscussionDetails.options") }
        public static var titleLabel: XCUIElement { app.find(id: "DiscussionDetails.title") }
        public static var lastPostLabel: XCUIElement {
            app.find(id: "DiscussionDetails.body").find(type: .staticText)
        }
        public static var messageLabel: XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(type: .staticText)[1]
        }
        public static var replyButton: XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(type: .link)[1]
        }
        public static var repliesSection: XCUIElement {
            app.find(id: "DiscussionDetails.body").find(label: "Replies", type: .other)
        }
        public static func replyToThreadButton(threadIndex: Int) -> XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(labelContaining: "Reply", type: .link)[threadIndex]
        }

        public struct Reply {
            public static var navBar: XCUIElement { app.find(id: "Reply") }
            public static var textField: XCUIElement {
                app.find(id: "RichContentEditor.webView").find(type: .textView)
            }
            public static var sendButton: XCUIElement {
                app.find(id: "DiscussionEditReply.sendButton")
            }
            public static var attachmentButton: XCUIElement {
                app.find(id: "DiscussionEditReply.attachmentButton")
            }
        }
    }

    // MARK: Other functions
    @discardableResult
    public static func createDiscussion(course: DSCourse,
                                        title: String = "Sample Discussion",
                                        message: String = "Message of ",
                                        isAnnouncement: Bool = false,
                                        published: Bool = true,
                                        isAssignment: Bool = false,
                                        dueDate: String? = nil) -> DSDiscussionTopic {
        let discussionAssignment = isAssignment ? CreateDSAssignmentRequest.RequestedDSAssignment(
            name: title, description: message + title, published: published, submission_types: [.online_text_entry], due_at: dueDate) : nil

        let discussionBody = CreateDSDiscussionRequest.RequestedDSDiscussion(
            title: title, message: message + title, is_announcement: isAnnouncement,
            published: published, assignment: discussionAssignment)
        return seeder.createDiscussion(courseId: course.id, requestBody: discussionBody)
    }

    public static func navigateToDiscussions(course: DSCourse) {
        DashboardHelper.courseCard(course: course).tap()
        CourseDetailsHelper.cell(type: .discussions).hit()
    }

    @discardableResult
    public static func replyToDiscussion(replyText: String = "Test replying to discussion", shouldPullToRefresh: Bool = false) -> Bool {
        Details.replyButton.tap()
        let textEntry = Details.Reply.textField.waitUntil(condition: .visible)
        textEntry.pasteText(text: replyText)
        Details.Reply.sendButton.hit()
        sleep(3)
        if shouldPullToRefresh {
            pullToRefresh()
        }
        let repliesSection = Details.repliesSection.waitUntil(condition: .visible)
        return repliesSection.isVisible
    }
}

public enum DiscussionLabelTypes: Int {
    case lastPost = 0
    case replies = 1
    case unread = 3
}
