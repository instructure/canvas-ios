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

public class InboxHelper: BaseHelper {
    public static var navBar: Element { app.find(id: "CanvasCore.HelmView") }
    public static var profileButton: Element { app.find(id: "Inbox.profileButton") }
    public static var newMessageButton: Element { app.find(id: "inbox.new-message") }

    public static func conversation(conversation: DSConversation) -> Element {
        app.find(id: "inbox.conversation-\(conversation.id)")
    }

    public static func addDateToSubject(subject: String, unread: Bool = false) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        let result = "\(formattedDate), \(subject)"
        return unread ? result + ", Unread" : result
    }

    public static func conversationBySubject(subject: String, unread: Bool = true) -> Element {
        let toFind = addDateToSubject(subject: subject, unread: unread)
        return app.find(label: toFind)
    }

    struct Filter {
        public static var all: Element { app.find(id: "inbox.filter-btn-all") }
        public static var unread: Element { app.find(id: "inbox.filter-btn-unread") }
        public static var starred: Element { app.find(id: "inbox.filter-btn-starred") }
        public static var sent: Element { app.find(id: "inbox.filter-btn-sent") }
        public static var archived: Element { app.find(id: "inbox.filter-btn-archived") }
        public static var byCourse: Element { app.find(id: "inbox.filterByCourse") }
    }

    struct Details {
        public static var navBar: Element { app.find(id: "Message Details") }
        public static var optionsButton: Element { app.find(id: "inbox.detail.options.button") }
        public static var replyButton: Element { app.find(id: "inbox.conversation-message-row.reply-button") }
        public static var starButton: Element { app.find(id: "inbox.detail.not-starred") }
        public static var unStarButton: Element { app.find(id: "inbox.detail.starred") }
        public static func subjectLabel(conversation: DSConversation) -> Element { app.find(label: conversation.subject) }

        public static func message(conversation: DSConversation) -> Element {
            app.find(id: "inbox.conversation-message-\(conversation.messages[0].id)")
        }

        public static func bodyOfMessage(conversation: DSConversation) -> Element {
            app.find(label: conversation.last_authored_message)
        }

        public static func messageOptions(conversation: DSConversation) -> Element {
            app.find(id: "conversation-message.kabob-\(conversation.messages[0].id)")
        }

        struct Options {
            public static var replyButton: Element { app.find(label: "Reply", type: .button) }
            public static var replyAllButton: Element { app.find(label: "Reply All", type: .button) }
            public static var forwardButton: Element { app.find(label: "Forward", type: .button) }
            public static var deleteButton: Element { app.find(label: "Delete", type: .button) }
            public static var cancelButton: Element { app.find(label: "Cancel", type: .button) }
        }
    }

    struct Composer {
        public static var cancelButton: Element { app.find(id: "compose-message.cancel") }
        public static var attachButton: Element { app.find(id: "compose-message.attach") }
        public static var sendButton: Element { app.find(id: "compose-message.send") }
        public static var courseSelectButton: Element { app.find(id: "compose.course-select") }
        public static var subjectInput: Element { app.find(id: "compose-message.subject-text-input") }
        public static var messageInput: Element { app.find(id: "compose-message.body-text-input") }
        public static var individualSwitch: Element { app.find(labelContaining: "individual", type: .switch) }
        public static var recipientsLabel: Element { app.find(id: "compose.recipients-placeholder") }
        public static var addRecipientButton: Element { app.find(id: "compose.add-recipient") }

        public static func courseSelectionItem(course: DSCourse) -> Element {
            app.find(id: "inbox.course-select.course-\(course.id)")
        }

        public static func recipientSelectionItem(course: DSCourse) -> Element {
            app.find(id: "branch_course_\(course.id)")
        }
    }

    public static func navigateToInbox() {
        TabBar.inboxTab.tap()
    }

    public static func logOut() {
        profileButton.tap()
        Profile.logOutButton.tap()
    }

    public static func sendMessage(course: DSCourse, student: DSUser, subject: String?, message: String?) {
        newMessageButton.tap()
        Composer.courseSelectButton.tap()
        Composer.courseSelectionItem(course: course).tap()
        Composer.addRecipientButton.tap()
        Composer.recipientSelectionItem(course: course).tap()
        Composer.subjectInput.tap().pasteText(subject ?? "Sample Subject of \(student.name)")
        Composer.messageInput.tap().pasteText(message ?? "Sample Message of \(student.name)")
        Composer.sendButton.tap()
    }

    @discardableResult
    public static func createConversation(course: DSCourse,
                                          subject: String = "Sample Message",
                                          body: String = "This is the body of the",
                                          recipients: [String]? = nil,
                                          archived: Bool = false) -> DSConversation {
        let finalRecipients = recipients ?? ["course_\(course.id)"]
        let requestBody = CreateDSConversationRequest.RequestedDSConversation(recipients: finalRecipients,
                                                                              subject: subject,
                                                                              body: "\(body) \(subject)",
                                                                              context_code: course.id,
                                                                              group_conversation: true)
        let result = seeder.createConversation(requestBody: requestBody)
        if archived {
            var progress = markConversationAsArchived(conversation: result)
            let deadline = Date().addingTimeInterval(120)
            while Date() < deadline {
                if progress.completion == 100 {
                    break
                }
                sleep(3)
                progress = seeder.getProgress(progressId: progress.id)
            }
        }
        return result
    }

    @discardableResult
    public static func markConversationAsArchived(conversation: DSConversation) -> DSProgress {
        return seeder.updateConversation(conversationId: conversation.id, event: .markAsArchived)
    }

    @discardableResult
    public static func editConversation(conversation: DSConversation,
                                        workflowState: DSWorkFlowState,
                                        scope: DSScope) -> DSConversation {
        return seeder.editConversation(conversationId: conversation.id, workflowState: workflowState, scope: scope)
    }
}
