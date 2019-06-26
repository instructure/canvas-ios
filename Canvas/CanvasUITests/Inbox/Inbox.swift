//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum Inbox {
    static var filterButton: Element {
        return app.find(id: "inbox.filterByCourse")
    }

    static var newMessageButton: Element {
        return app.find(id: "inbox.new-message")
    }

    static func filterOption(_ text: String) -> Element {
        return app.find(labelContaining: "Assignments")
    }

    static func message(id: String) -> Element {
        return app.find(id: "inbox.conversation-\(id)")
    }
}

enum NewMessage {
    static var selectCourseButton: Element {
        return app.find(id: "compose.course-select")
    }

    static var addRecipientButton: Element {
        return app.find(id: "compose.add-recipient")
    }
}

enum MessageCourseSelection {
    static func course(id: String) -> Element {
        return app.find(id: "inbox.course-select.course-\(id)")
    }
}

enum MessageRecipientsSelection {
    static func messageAllInCourse(courseID: String) -> Element {
        return app.find(id: "branch_course_\(courseID)")
    }

    static func studentsInCourse(courseID: String) -> Element {
        return app.find(id: "course_\(courseID)_students")
    }

    static func messageAllStudents(courseID: String) -> Element {
        return app.find(id: "branch_course_\(courseID)_students")
    }

    static func student(studentID: String) -> Element {
        return app.find(id: studentID)
    }
}
