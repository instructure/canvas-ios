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
    public static var profileButton: XCUIElement { app.find(id: "Inbox.profileButton", type: .button) }
    public static var newMessageButton: XCUIElement { app.find(id: "Inbox.newMessageButton", type: .button) }
    public static var filterByCourseButton: XCUIElement { app.find(id: "Inbox.filterByCourse") }
    public static var filterByTypeButton: XCUIElement { app.find(id: "Inbox.filterByType") }

    public static func conversation(conversation: DSConversation) -> XCUIElement {
        return app.find(id: "Conversation.\(conversation.id)")
    }

    public static func conversationDateLabel(conversation: DSConversation) -> XCUIElement {
        return app.find(id: "Conversation.\(conversation.id).date")
    }

    public static func conversationParticipantLabel(conversation: DSConversation) -> XCUIElement {
        return app.find(id: "Conversation.\(conversation.id).participantName")
    }

    public static func conversationTitleLabel(conversation: DSConversation) -> XCUIElement {
        return app.find(id: "Conversation.\(conversation.id).title")
    }

    public static func conversationMessageLabel(conversation: DSConversation) -> XCUIElement {
        return app.find(id: "Conversation.\(conversation.id).message")
    }

    public static var conversations: [XCUIElement] { app.findAll(idStartingWith: "Conversation.") }

    public static func addDateToSubject(subject: String, unread: Bool) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL d, yyyy"
        let formattedDate = dateFormatter.string(from: date)
        let result = "\(formattedDate), \(subject)"
        return unread ? result + ", Unread" : result
    }

    public static func conversationBySubject(subject: String) -> XCUIElement {
        return app.find(label: subject, type: .staticText)
    }

    public struct Filter {
        public static var cancelButton: XCUIElement { app.find(label: "Cancel", type: .button) }

        // Filter by course
        public static var allCourses: XCUIElement { app.find(label: "All Courses", type: .button) }
        public static func course(course: DSCourse) -> XCUIElement { app.find(label: course.name, type: .button) }

        // Filter by type
        public static var inbox: XCUIElement { app.find(label: "Inbox", type: .button) }
        public static var unread: XCUIElement { app.find(label: "Unread", type: .button) }
        public static var starred: XCUIElement { app.find(label: "Starred", type: .button) }
        public static var sent: XCUIElement { app.find(label: "Sent", type: .button) }
        public static var archived: XCUIElement { app.find(label: "Archived", type: .button) }
    }

    public struct Details {
        public static var optionsButton: XCUIElement { app.find(id: "MessageDetails.options") }
        public static var moreButton: XCUIElement { app.find(id: "MessageDetails.more", type: .button) }
        public static var replyImage: XCUIElement { app.find(id: "MessageDetails.replyImage") }
        public static var replyButton: XCUIElement { app.find(id: "MessageDetails.replyButton") }
        public static var authorLabel: XCUIElement { app.find(id: "MessageDetails.author") }
        public static var starButton: XCUIElement { app.find(id: "MessageDetails.star") }
        public static var unstarButton: XCUIElement { app.find(id: "MessageDetails.unstar") }
        public static var dateLabel: XCUIElement { app.find(id: "MessageDetails.date") }
        public static var bodyLabel: XCUIElement { app.find(id: "MessageDetails.body") }
        public static var subjectLabel: XCUIElement { app.find(id: "MessageDetails.subject") }

        public struct Options {
            public static var replyButton: XCUIElement { app.find(id: "MessageDetails.reply") }
            public static var replyAllButton: XCUIElement { app.find(id: "MessageDetails.replyAll") }
            public static var forwardButton: XCUIElement { app.find(id: "MessageDetails.forward") }
            public static var deleteButton: XCUIElement { app.find(id: "MessageDetails.delete") }
            public static var markAsUnreadButton: XCUIElement { app.find(id: "MessageDetails.markAsUnread") }
            public static var markAsReadButton: XCUIElement { app.find(id: "MessageDetails.markAsRead") }
            public static var archiveButton: XCUIElement { app.find(id: "MessageDetails.archive") }
            public static var unarchiveButton: XCUIElement { app.find(id: "MessageDetails.unarchive") }
        }
    }

    public struct Composer {
        public static var cancelButton: XCUIElement { app.find(id: "ComposeMessage.cancel") }
        public static var subjectLabel: XCUIElement { app.find(id: "ComposeMessage.subjectLabel") }
        public static var sendButton: XCUIElement { app.find(id: "ComposeMessage.send") }
        public static var selectCourseButton: XCUIElement { app.find(id: "ComposeMessage.course", type: .button) }
        public static var subjectInput: XCUIElement { app.find(id: "ComposeMessage.subjectInput") }
        public static var individualToggle: XCUIElement { app.find(id: "ComposeMessage.individual").find(type: .switch) }
        public static var addAttachmentButton: XCUIElement { app.find(id: "ComposeMessage.attachment") }
        public static var addRecipientButton: XCUIElement { app.find(id: "ComposeMessage.addRecipient").find(type: .button) }
        public static var bodyInput: XCUIElement { app.find(id: "ComposeMessage.body") }

        public static func courseItem(course: DSCourse) -> XCUIElement {
            return app.find(id: "Inbox.course.\(course.id)")
        }

        public static func recipientPillById(recipient: DSUser) -> XCUIElement {
            return app.find(id: "ComposeMessage.recipientPill.\(recipient.id)", type: .button)
        }

        public static func recipientPillByRole(role: String) -> XCUIElement {
            return app.find(id: "ComposeMessage.recipientPill.all\(role)", type: .button)
        }

        public static func recipient(user: DSUser) -> XCUIElement {
            return app.find(id: "ComposeMessage.recipient.\(user.id)", type: .button)
        }

        public struct Attachments {
            public static var addButton: XCUIElement { app.find(id: "attachments.add-btn") }
            public static var dismissButton: XCUIElement { app.find(id: "attachments.dismiss-btn") }
        }

        public struct Recipients {
            public static var students: XCUIElement { app.find(id: "Inbox.addRecipient.allStudents", type: .button) }
            public static var teachers: XCUIElement { app.find(id: "Inbox.addRecipient.allTeachers", type: .button) }
            public static var doneButton: XCUIElement { app.find(id: "Inbox.addRecipient.done") }

            public static func allInCourse(course: DSCourse) -> XCUIElement {
                return app.find(id: "Inbox.addRecipient.allIn.\(course.id)", type: .button)
            }

            public static func userItem(user: DSUser) -> XCUIElement {
                return app.find(id: user.id)
            }
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
        Composer.selectCourseButton.hit()
        Composer.courseItem(course: course).hit()
        Composer.addRecipientButton.hit()
        Composer.Recipients.allInCourse(course: course).hit()
        Composer.subjectInput.hit().pasteText(text: subject ?? "Sample Subject of \(student.name)")
        Composer.bodyInput.hit().pasteText(text: message ?? "Sample Message of \(student.name)")
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
    public static var newMessageButton: XCUIElement { app.find(id: "ConversationList.composeButton") }

    public struct Compose {
        public static var cancelButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static var addAttachmentButton: XCUIElement { app.find(label: "Add Attachments", type: .button) }
        public static var sendButton: XCUIElement { app.find(label: "Send", type: .button) }
        public static var recipientsButton: XCUIElement { app.find(label: "Edit Recipients", type: .button) }
        public static var subjectInput: XCUIElement { app.find(id: "Compose.subject") }
        public static var messageInput: XCUIElement { app.find(id: "Compose.body") }
    }

    public struct Reply {
        public static var cancelButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static var attachButton: XCUIElement { app.find(id: "ComposeReply.attachButton") }
        public static var sendButton: XCUIElement { app.find(id: "ComposeReply.sendButton") }
        public static var body: XCUIElement { app.find(id: "ComposeReply.body") }
    }

    public struct Details {
        public static var replyButton: XCUIElement { app.find(id: "ConversationDetail.replyButton") }

        public static func subjectLabel(conversation: DSConversation) -> XCUIElement {
            return app.find(label: conversation.subject, type: .staticText)
        }

        public static func messageLabel(conversation: DSConversation) -> XCUIElement {
            return app.find(label: conversation.last_authored_message, type: .textView)
        }

        public static func cell(conversation: DSConversation) -> XCUIElement {
            return app.find(id: "ConversationDetailCell.\(conversation.id)")
        }
    }

    public static func courseButton(course: DSCourse) -> XCUIElement {
        return app.find(label: course.name, type: .staticText)
    }

    public static func conversation(conversation: DSConversation? = nil, conversationId: String? = nil) -> XCUIElement {
        return app.find(id: "ConversationListCell.\(conversation?.id ?? conversationId!)")
    }

    public static func conversationBySubject(subject: String) -> XCUIElement {
        return app.find(labelContaining: subject, type: .cell)
    }
}
