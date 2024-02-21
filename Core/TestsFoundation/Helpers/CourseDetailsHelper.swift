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

public class CourseDetailsHelper: BaseHelper {
    public enum CellType: String {
        case home = "home"
        case announcements = "announcements"
        case assignments = "assignments"
        case discussions = "discussions"
        case grades = "grades"
        case people = "people"
        case pages = "pages"
        case syllabus = "syllabus"
        case modules = "modules"
        case bigBlueButton = "conferences"
        case collaborations = "collaborations"
        case googleDrive = "context_external_tool_1038049"
        case quizzes = "quizzes"
        case files = "files"
        case studio = "context_external_tool_955147"
        case studentView = "student_view"
    }

    public static var titleLabel: XCUIElement { app.find(id: "course-details.title-lbl") }
    public static var subtitleLabel: XCUIElement { app.find(id: "course-details.subtitle-lbl") }

    public static func cell(type: CellType) -> XCUIElement { return app.find(id: "courses-details.\(type.rawValue)-cell") }
}

public class CourseDetailsHelperParent: BaseHelper {
    public static var totalGradeLabel: XCUIElement { app.find(id: "CourseTotalGrade") }
    public static var pandaSpaceImage: XCUIElement { app.find(id: "PandaSpace", type: .image) }

    public static func assignmentCell(assignment: DSAssignment) -> XCUIElement {
        return app.find(id: "GradeListCell.\(assignment.id)")
    }

    public static func letterGradeLabelOfAssignmentCell(assignment: DSAssignment, letterGrade: String) -> XCUIElement {
        return assignmentCell(assignment: assignment).find(labelContaining: "(\(letterGrade))")
    }
}
