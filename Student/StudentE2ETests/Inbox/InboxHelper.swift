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
    public static var newMessageButton: Element { app.find(id: "inbox.new-message") }

    public static func conversation(conversation: DSConversation) -> Element {
        app.find(id: "inbox.conversation-\(conversation.id)")
    }

    public static func conversationBySubject(subject: String) -> Element {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        let month = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "d"
        let day = dateFormatter.string(from: date)
        return app.find(label: "\(month) \(day), \(year), \(subject)")
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

        public static func message(conversation: DSConversation) -> Element {
            app.find(id: "inbox.conversation-message-\(conversation.id)")
        }
        
        public static func messageOptions(conversation: DSConversation) -> Element {
            app.find(id: "inbox.conversation-message.kabob-\(conversation.id)")
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
            app.find(id: "branch_course_\(course)")
        }
    }

    public static func navigateToInbox() {
        TabBar.inboxTab.tap()
    }

    @discardableResult
    public static func createConversation(course: DSCourse,
                                          subject: String = "Message",
                                          body: String = "This is the body of the",
                                          recipients: [String]? = nil,
                                          scope: ConversationScope? = nil) -> DSConversation {
        let finalRecipients = recipients ?? ["course_\(course.id)"]
        let finalSubject = "\(scope?.rawValue.capitalized ?? "The") \(subject)"
        let finalBody = "This is the body of \(finalSubject)"
        let requestBody = CreateDSConversationRequest.RequestedDSConversation(recipients: finalRecipients,
                                                                              subject: finalSubject,
                                                                              body: finalBody,
                                                                              context_code: course.id,
                                                                              group_conversation: true,
                                                                              scope: scope ?? .unread)
        return seeder.createConversation(requestBody: requestBody)
    }
}
