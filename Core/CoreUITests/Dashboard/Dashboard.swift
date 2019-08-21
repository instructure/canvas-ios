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

public enum CourseInvitation {
    public static func acted(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).acted")
    }

    public static func acceptButton(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).acceptButton")
    }

    public static func rejectButton(id: String) -> Element {
        return app.find(id: "CourseInvitation.\(id).rejectButton")
    }
}

public enum Dashboard: String, ElementWrapper {
    case addCoursesButton, emptyBodyLabel, emptyTitleLabel

    public static var coursesLabel: Element {
        return app.find(id: "dashboard.courses.heading-lbl")
    }

    public static var seeAllButton: Element {
        return app.find(id: "dashboard.courses.see-all-btn")
    }

    public static func courseCard(id: String) -> Element {
        return app.find(id: "course-\(id)")
    }

    public static func courseGrade(percent: String) -> Element {
        return app.find(labelContaining: "\(percent)%")
    }

    public static func groupCard(id: String) -> Element {
        return app.find(id: "group-row-\(id)")
    }

    public static var profileButton: Element {
        return app.find(id: "favorited-course-list.profile-btn")
    }
}
