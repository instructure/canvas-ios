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

public enum Inbox: String, RawElementWrapper {
    case filterButton = "inbox.filterByCourse"
    case newMessageButton = "inbox.new-message"
    case sentButton = "inbox.filter-btn-sent"

    public static func filterOption(_ text: String) -> Element {
        return app.find(labelContaining: "Assignments")
    }

    public static func message(id: String) -> Element {
        return app.find(id: "inbox.conversation-\(id)")
    }
}

public enum NewMessage: String, RawElementWrapper {
    case selectCourseButton = "compose.course-select"
    case addRecipientButton = "compose.add-recipient"
    case replyButton = "inbox.conversation-message-row.reply-button"
    case subjectTextView = "compose-message.subject-text-input"
    case bodyTextView = "compose-message.body-text-input"
    case sendButton = "compose-message.send"
    case attachButton = "compose-message.attach"
    case cancelButton = "compose-message.cancel"

    public static func recipientLabel(id: String) -> Element {
        return app.find(id: "message-recipient.\(id).label")
    }

    public static func recipientDeleteButton(id: String) -> Element {
        return app.find(id: "message-recipient.\(id).delete-btn")
    }
}

public enum MessageCourseSelection {
    public static func course(id: String) -> Element {
        return app.find(id: "inbox.course-select.course-\(id)")
    }
}

public enum MessageRecipientsSelection {
    public static func messageAllInCourse(courseID: String) -> Element {
        return app.find(id: "branch_course_\(courseID)")
    }

    public static func studentsInCourse(courseID: String) -> Element {
        return app.find(id: "course_\(courseID)_students")
    }

    public static func messageAllStudents(courseID: String) -> Element {
        return app.find(id: "branch_course_\(courseID)_students")
    }

    public static func student(studentID: String) -> Element {
        return app.find(id: studentID)
    }
}
