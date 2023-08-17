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

public class InboxHelper: BaseHelper {
    public static var navBar: XCUIElement { app.find(id: "CanvasCore.HelmView") }
    public static var profileButton: XCUIElement { app.find(id: "Inbox.profileButton") }
    public static var newMessageButton: XCUIElement { app.find(id: "inbox.new-message") }

    public static func conversation(conversation: DSConversation? = nil, conversationId: String? = nil) -> XCUIElement {
        return app.find(id: "inbox.conversation-\(conversation?.id ?? conversationId!)")
    }

    public static func addDateToSubject(subject: String, unread: Bool) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        let result = "\(formattedDate), \(subject)"
        return unread ? result + ", Unread" : result
    }

    public static func conversationBySubject(subject: String, unread: Bool = true) -> XCUIElement {
        let stringToFind = addDateToSubject(subject: subject, unread: unread)
        return app.find(label: stringToFind)
    }

    public struct Filter {
        public static var all: XCUIElement { app.find(id: "inbox.filter-btn-all") }
        public static var unread: XCUIElement { app.find(id: "inbox.filter-btn-unread") }
        public static var starred: XCUIElement { app.find(id: "inbox.filter-btn-starred") }
        public static var sent: XCUIElement { app.find(id: "inbox.filter-btn-sent") }
        public static var archived: XCUIElement { app.find(id: "inbox.filter-btn-archived") }
        public static var byCourse: XCUIElement { app.find(id: "inbox.filterByCourse") }
    }

    public struct Details {
        public static var navBar: XCUIElement { app.find(id: "Message Details") }
        public static var optionsButton: XCUIElement { app.find(id: "inbox.detail.options.button") }
        public static var replyButton: XCUIElement { app.find(id: "inbox.conversation-message-row.reply-button") }
        public static var starButton: XCUIElement { app.find(id: "inbox.detail.not-starred") }
        public static var unStarButton: XCUIElement { app.find(id: "inbox.detail.starred") }
        public static func subjectLabel(conversation: DSConversation) -> XCUIElement { app.find(label: conversation.subject) }

        public static func message(conversation: DSConversation) -> XCUIElement {
            return app.find(id: "inbox.conversation-message-\(conversation.messages[0].id)")
        }

        public static func bodyOfMessage(conversation: DSConversation) -> XCUIElement {
            return app.find(label: conversation.last_authored_message)
        }

        public static func messageOptions(conversation: DSConversation) -> XCUIElement {
            return app.find(id: "conversation-message.kabob-\(conversation.messages[0].id)")
        }

        public struct Options {
            public static var replyButton: XCUIElement { app.find(label: "Reply", type: .button) }
            public static var replyAllButton: XCUIElement { app.find(label: "Reply All", type: .button) }
            public static var forwardButton: XCUIElement { app.find(label: "Forward", type: .button) }
            public static var deleteButton: XCUIElement { app.find(label: "Delete", type: .button) }
            public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }
        }
    }

    public struct Composer {
        public static var cancelButton: XCUIElement { app.find(id: "compose-message.cancel") }
        public static var attachButton: XCUIElement { app.find(id: "compose-message.attach") }
        public static var sendButton: XCUIElement { app.find(id: "compose-message.send") }
        public static var courseSelectButton: XCUIElement { app.find(id: "compose.course-select") }
        public static var subjectInput: XCUIElement { app.find(id: "compose-message.subject-text-input") }
        public static var messageInput: XCUIElement { app.find(id: "compose-message.body-text-input") }
        public static var individualSwitch: XCUIElement { app.find(labelContaining: "individual", type: .switch) }
        public static var recipientsLabel: XCUIElement { app.find(id: "compose.recipients-placeholder") }
        public static var addRecipientButton: XCUIElement { app.find(id: "compose.add-recipient") }

        public static func courseSelectionItem(course: DSCourse? = nil, courseId: String? = nil) -> XCUIElement {
            return app.find(id: "inbox.course-select.course-\(course?.id ?? courseId!)")
        }

        public static func recipientSelectionItem(course: DSCourse? = nil, courseId: String? = nil) -> XCUIElement {
            return app.find(id: "branch_course_\(course?.id ?? courseId!)")
        }

        public struct Attachments {
            public static var addButton: XCUIElement { app.find(id: "attachments.add-btn") }
            public static var dismissButton: XCUIElement { app.find(id: "attachments.dismiss-btn") }
        }
    }

    public static func navigateToInbox() {
        BaseHelper.TabBar.inboxTab.hit()
    }

    public static func logOut() {
        profileButton.hit()
        ProfileHelper.logOutButton.hit()
    }

    public static func sendMessage(course: DSCourse, student: DSUser, subject: String?, message: String?) {
        newMessageButton.hit()
        Composer.courseSelectButton.hit()
        Composer.courseSelectionItem(course: course).hit()
        Composer.addRecipientButton.hit()
        Composer.recipientSelectionItem(course: course).hit()
        Composer.subjectInput.hit().pasteText(text: subject ?? "Sample Subject of \(student.name)")
        Composer.messageInput.hit().pasteText(text: message ?? "Sample Message of \(student.name)")
        Composer.sendButton.hit()
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

public class InboxHelperParent: BaseHelper {
    public static var replyButton: XCUIElement { app.find(id: "ConversationDetail.replyButton") }
    public static func conversation(conversation: DSConversation? = nil, conversationId: String? = nil) -> XCUIElement {
        return app.find(id: "ConversationListCell.\(conversation?.id ?? conversationId!)")
    }

    public struct Reply {
        public static var body: XCUIElement { app.find(id: "ComposeReply.body") }
    }
}
