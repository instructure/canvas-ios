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

public enum DiscussionLabelTypes: Int {
    case lastPost = 0
    case replies = 1
    case unread = 3
}

public class DiscussionsHelper: BaseHelper {
    public static var newButton: XCUIElement { app.find(id: "DiscussionList.newButton") }
    public static var noDiscussionsPandaImage: XCUIElement { app.find(id: "PandaNoDiscussions") }

    public static func discussionButton(discussion: DSDiscussionTopic? = nil, discussionId: String? = nil) -> XCUIElement {
        app.find(id: "DiscussionListCell.\(discussion?.id ?? discussionId!)")
    }

    public static func discussionDataLabel(discussion: DSDiscussionTopic, label: DiscussionLabelTypes) -> XCUIElement {
        discussionButton(discussion: discussion).findAll(type: .staticText, minimumCount: 4)[label.rawValue]
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
        public static var editButton: XCUIElement { app.find(id: "DiscussionDetails.edit") }
        public static var lastPostLabel: XCUIElement {
            app.find(id: "DiscussionDetails.body").find(type: .staticText)
        }
        public static var messageLabel: XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(type: .staticText, minimumCount: 2)[1]
        }
        public static var replyButton: XCUIElement {
            app.find(id: "DiscussionDetails.body").findAll(type: .link, minimumCount: 2)[1]
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

    public struct Editor {
        public static var allowRatingToggle: XCUIElement { app.find(id: "DiscussionEditor.allowRatingToggle") }
        public static var attachmentButton: XCUIElement { app.find(id: "DiscussionEditor.attachmentButton") }
        public static var delayedPostAtToggle: XCUIElement { app.find(id: "DiscussionEditor.delayedPostAtToggle") }
        public static var delayedPostAtPicker: XCUIElement { app.find(id: "DiscussionEditor.delayedPostAtPicker") }
        public static var doneButton: XCUIElement { app.find(id: "DiscussionEditor.doneButton") }
        public static var gradingTypeButton: XCUIElement { app.find(id: "DiscussionEditor.gradingTypeButton") }
        public static var lockAtPicker: XCUIElement { app.find(id: "DiscussionEditor.lockAtPicker") }
        public static var lockedToggle: XCUIElement { app.find(id: "DiscussionEditor.lockedToggle") }
        public static var onlyGradersCanRateToggle: XCUIElement { app.find(id: "DiscussionEditor.onlyGradersCanRateToggle") }
        public static var pointsField: XCUIElement { app.find(id: "DiscussionEditor.pointsField") }
        public static var publishedToggle: XCUIElement { app.find(id: "DiscussionEditor.publishedToggle") }
        public static var requireInitialPostToggle: XCUIElement { app.find(id: "DiscussionEditor.requireInitialPostToggle") }
        public static var sectionsButton: XCUIElement { app.find(id: "DiscussionEditor.sectionsButton") }
        public static var sortByRatingToggle: XCUIElement { app.find(id: "DiscussionEditor.sortByRatingToggle") }
        public static var threadedToggle: XCUIElement { app.find(id: "DiscussionEditor.threadedToggle") }
        public static var titleField: XCUIElement { app.find(id: "DiscussionEditor.titleField") }

        public static var richContentEditorWebView: XCUIElement { app.find(id: "RichContentEditor.webView") }
    }

    // MARK: Other functions
    @discardableResult
    public static func createDiscussion(course: DSCourse,
                                        title: String = "Sample Discussion",
                                        message: String = "Message of ",
                                        isAnnouncement: Bool = false,
                                        published: Bool = true,
                                        isAssignment: Bool = false,
                                        dueDate: Date? = nil) -> DSDiscussionTopic {
        let discussionAssignment = isAssignment ? CreateDSAssignmentRequest.RequestedDSAssignment(
            name: title, description: message + title, published: published, submission_types: [.online_text_entry], due_at: dueDate) : nil

        let discussionBody = CreateDSDiscussionRequest.RequestedDSDiscussion(
            title: title, message: message + title, is_announcement: isAnnouncement,
            published: published, assignment: discussionAssignment)
        return seeder.createDiscussion(courseId: course.id, requestBody: discussionBody)
    }

    public static func navigateToDiscussions(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .discussions).hit()
    }

    @discardableResult
    public static func replyToDiscussion(replyText: String = "Test replying to discussion", shouldPullToRefresh: Bool = false) -> Bool {
        Details.replyButton.hit()
        let textEntry = Details.Reply.textField.waitUntil(.visible)
        textEntry.pasteText(text: replyText)
        Details.Reply.sendButton.hit()
        sleep(3)
        if shouldPullToRefresh {
            pullToRefresh()
        }
        let repliesSection = Details.repliesSection.waitUntil(.visible)
        return repliesSection.isVisible
    }
}
