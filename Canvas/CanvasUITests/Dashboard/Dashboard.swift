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

enum CourseInvitation {
    static func acted(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).acted")
    }

    static func acceptButton(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).acceptButton")
    }

    static func rejectButton(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).rejectButton")
    }
}

enum Dashboard {
    static var coursesLabel: Element {
        return app.find(labelContaining: "Courses")
    }

    static func courseCard(id: String) -> Element {
        return app.find(id: "course-\(id)")
    }

    static func courseGrade(percent: String) -> Element {
        return app.find(labelContaining: "\(percent)%")
    }

    static var dashboardTab: Element {
        return app.find(label: "Dashboard")
    }

    static var calendarTab: Element {
        return app.find(label: "Calendar")
    }

    static var inboxTab: Element {
        return app.find(id: "tab-bar.inbox-btn")
    }

    static var profileButton: Element {
        return app.find(id: "favorited-course-list.profile-btn")
    }
}

enum GlobalAnnouncement {
    static func toggle(id: String) -> Element {
        return app.find(id: "GlobalAnnouncement.\(id).toggle")
    }

    static func dismiss(id: String) -> Element {
        return app.find(id: "GlobalAnnouncement.\(id).dismiss")
    }
}
