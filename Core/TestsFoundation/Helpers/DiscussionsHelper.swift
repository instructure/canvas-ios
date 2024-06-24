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
        return app.find(id: "DiscussionListCell.\(discussion?.id ?? discussionId!)")
    }

    public static func discussionButtonByLabel(label: String) -> XCUIElement {
        return app.find(labelContaining: label, type: .cell)
    }

    public static func discussionDataLabel(discussion: DSDiscussionTopic, label: DiscussionLabelTypes) -> XCUIElement? {
        let result = discussionButton(discussion: discussion).findAll(type: .staticText, minimumCount: 4)
        return result.count >= label.rawValue ? result[label.rawValue] : nil
    }

    public static func discussionsNavBar(course: DSCourse) -> XCUIElement {
        return app.find(id: "Discussions, \(course.name)")
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
        public static var backButton: XCUIElement {
            app.find(idStartingWith: "Discussion Details", type: .navigationBar).find(label: "Back", type: .button)
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

    public struct NewDetails {
        public static var searchField: XCUIElement { app.find(type: .textField) }
        public static var filterByLabel: XCUIElement { app.find(label: "Filter by", type: .staticText) }
        public static var sortButton: XCUIElement { app.find(labelContaining: "Sorted by", type: .button) }
        public static var viewSplitScreenButton: XCUIElement { app.find(labelContaining: "View Split Screen", type: .button) }
        public static var viewInlineButton: XCUIElement { app.find(labelContaining: "View Inline", type: .button) }
        public static var manageDiscussionButton: XCUIElement { app.find(label: "Manage Discussion", type: .button) }
        public static var subscribeButton: XCUIElement { app.find(label: "Unsubscribed", type: .button) }
        public static var unsubscribeButton: XCUIElement { app.find(label: "Subscribed", type: .button) }
        public static var replyButton: XCUIElement { app.find(label: "Reply", type: .button) }
        public static var markAllAsRead: XCUIElement { app.find(label: "Mark All as Read", type: .menuItem) }
        public static var markAllAsUnread: XCUIElement { app.find(label: "Mark All as Unread", type: .menuItem) }

        public static func replyFromLabel(user: DSUser) -> XCUIElement {
            return app.find(label: "Reply from \(user.name)", type: .staticText)
        }
        
        public static func replyBody(replyText: String) -> XCUIElement {
            return app.find(label: replyText, type: .staticText)
        }
        
        public static func replyToPostButton(user: DSUser) -> XCUIElement {
            return app.find(label: "Reply to post from \(user.name)", type: .button)
        }

        public static func discussionTitle(discussion: DSDiscussionTopic) -> XCUIElement {
            return app.find(label: "Discussion Topic: \(discussion.title)", type: .staticText)
        }

        public static func discussionBody(discussion: DSDiscussionTopic) -> XCUIElement {
            return app.find(label: discussion.message, type: .staticText)
        }

        public struct Reply {
            public static var textInput: XCUIElement { app.find(labelContaining: "Rich Text Area", type: .other).find(type: .textField) }
            public static var attachButton: XCUIElement { app.find(label: "Attach", type: .button) }
            public static var replyButton: XCUIElement { app.find(label: "Reply", type: .button) }
            public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }

            public static func replyButtons(count: Int) -> [XCUIElement] {
                let deadline = Date().addingTimeInterval(10)
                while Date() < deadline {
                    let replyButtons = app.findAll(label: "Reply", type: .button)
                    if replyButtons.count > count - 1 {
                        return replyButtons
                    } else {
                        sleep(1)
                    }
                }
                return []
            }
        }

    }

    public struct Editor {
        public static var allowRatingToggle: XCUIElement { app.find(id: "DiscussionEditor.allowRatingToggle").find(type: .switch) }
        public static var attachmentButton: XCUIElement { app.find(id: "DiscussionEditor.attachmentButton") }
        public static var delayedPostAtToggle: XCUIElement { app.find(id: "DiscussionEditor.delayedPostAtToggle") }
        public static var delayedPostAtPicker: XCUIElement { app.find(id: "DiscussionEditor.delayedPostAtPicker") }
        public static var doneButton: XCUIElement { app.find(id: "DiscussionEditor.doneButton") }
        public static var gradingTypeButton: XCUIElement { app.find(id: "DiscussionEditor.gradingTypeButton") }
        public static var lockAtPicker: XCUIElement { app.find(id: "DiscussionEditor.lockAtPicker") }
        public static var lockedToggle: XCUIElement { app.find(id: "DiscussionEditor.lockedToggle") }
        public static var onlyGradersCanRateToggle: XCUIElement { app.find(id: "DiscussionEditor.onlyGradersCanRateToggle") }
        public static var pointsField: XCUIElement { app.find(id: "DiscussionEditor.pointsField") }
        public static var publishedToggle: XCUIElement { app.find(id: "DiscussionEditor.publishedToggle").find(type: .switch) }
        public static var requireInitialPostToggle: XCUIElement { app.find(id: "DiscussionEditor.requireInitialPostToggle").find(type: .switch) }
        public static var sectionsButton: XCUIElement { app.find(id: "DiscussionEditor.sectionsButton") }
        public static var sortByRatingToggle: XCUIElement { app.find(id: "DiscussionEditor.sortByRatingToggle") }
        public static var threadedToggle: XCUIElement { app.find(id: "DiscussionEditor.threadedToggle").find(type: .switch) }
        public static var titleField: XCUIElement { app.find(id: "DiscussionEditor.titleField") }
        public static var availableFromButton: XCUIElement { app.find(label: "Available from", type: .button) }
        public static var availableUntilButton: XCUIElement { app.find(label: "Available until", type: .button) }
        public static var descriptionField: XCUIElement { richContentEditorWebView.find(type: .textView) }

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
            name: title, description: message + title, published: published, submission_types: [.discussion_topic], due_at: dueDate) : nil

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
        NewDetails.replyButton.hit()
        let textInput = NewDetails.Reply.textInput.waitUntil(.visible)
        let replyButton = NewDetails.Reply.replyButton.waitUntil(.visible)
        textInput.writeText(text: replyText)
        replyButton.hit()
        textInput.waitUntil(.vanish)
        return NewDetails.replyBody(replyText: replyText).waitUntil(.visible).isVisible
    }
}
