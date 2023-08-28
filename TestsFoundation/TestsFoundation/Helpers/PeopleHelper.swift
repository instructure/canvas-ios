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

public class PeopleHelper: BaseHelper {
    public static func navigateToPeople(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.cell(type: .people).hit()
    }

    public static func navBar(course: DSCourse) -> XCUIElement {
        return app.find(id: "People, \(course.name)")
    }

    public static var filterButton: XCUIElement {
        app.find(id: "All People").find(label: "Filter", type: .button)
    }

    public static func peopleCell(index: Int) -> XCUIElement {
        return app.find(id: "people-list-cell-row-\(index)")
    }

    public static func roleLabelOfPeopleCell(index: Int) -> XCUIElement {
        return app.find(id: "people-list-cell-row-\(index).role-label")
    }

    public static func nameLabelOfPeopleCell(index: Int) -> XCUIElement {
        return app.find(id: "people-list-cell-row-\(index).name-label")
    }

    public struct ContextCard {
        public static var userNameLabel: XCUIElement { app.find(id: "ContextCard.userNameLabel") }
        public static var userEmailLabel: XCUIElement { app.find(id: "ContextCard.userEmailLabel") }
        public static var courseLabel: XCUIElement { app.find(id: "ContextCard.courseLabel") }
        public static var sectionLabel: XCUIElement { app.find(id: "ContextCard.sectionLabel") }
        public static var currentGradeLabel: XCUIElement { app.find(id: "ContextCard.currentGradeLabel") }
        public static var lastActivityLabel: XCUIElement { app.find(id: "ContextCard.lastActivityLabel") }
        public static var overrideGradeLabel: XCUIElement { app.find(id: "ContextCard.overrideGradeLabel") }
        public static var submissionsLateLabel: XCUIElement { app.find(id: "ContextCard.submissionsLateLabel") }
        public static var submissionsMissingLabel: XCUIElement { app.find(id: "ContextCard.submissionsMissingLabel") }
        public static var submissionsTotalLabel: XCUIElement { app.find(id: "ContextCard.submissionsTotalLabel") }
        public static var unpostedGradeLabel: XCUIElement { app.find(id: "ContextCard.unpostedGradeLabel") }

        public static func submissionCell(assignment: DSAssignment? = nil, assignmentId: String? = nil) -> XCUIElement {
            return app.find(id: "ContextCard.submissionCell(\(assignment?.id ?? assignmentId!))")
        }
    }
}
