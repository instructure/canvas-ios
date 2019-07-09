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

enum Dashboard: String, ElementWrapper {
    case addCoursesButton, emptyBodyLabel, emptyTitleLabel

    static var coursesLabel: Element {
        return app.find(id: "dashboard.courses.heading-lbl")
    }

    static var seeAllButton: Element {
        return app.find(id: "dashboard.courses.see-all-btn")
    }

    static func courseCard(id: String) -> Element {
        return app.find(id: "course-\(id)")
    }

    static func courseGrade(percent: String) -> Element {
        return app.find(labelContaining: "\(percent)%")
    }

    static func groupCard(id: String) -> Element {
        return app.find(id: "group-row-\(id)")
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
