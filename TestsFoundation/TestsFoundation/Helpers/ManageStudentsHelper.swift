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

public class ManageStudentsHelper: BaseHelper {
    public struct Details {
        public static var backButton: XCUIElement { app.find(label: "Manage Students", type: .button) }
        public static var navBar: XCUIElement { app.find(id: "Parent.StudentDetailsView") }
        public static var courseGradeAbove: XCUIElement { app.find(id: "AlertThreshold.course_grade_high") }
        public static var courseGradeBelow: XCUIElement { app.find(id: "AlertThreshold.course_grade_low") }
        public static var assignmentMissing: XCUIElement { app.find(id: "AlertThreshold.assignment_missing") }
        public static var assignmentGradeAbove: XCUIElement { app.find(id: "AlertThreshold.assignment_grade_high") }
        public static var assignmentGradeBelow: XCUIElement { app.find(id: "AlertThreshold.assignment_grade_low") }
        public static var courseAnnouncements: XCUIElement { app.find(id: "AlertThreshold.course_announcement") }
        public static var institutionAnnouncements: XCUIElement { app.find(id: "AlertThreshold.institution_announcement") }
    }

    public static func studentCell(student: DSUser) -> XCUIElement? {
        let studentCells = app.findAll(idStartingWith: "StudentListCell", type: .cell)
        for studentCell in studentCells {
            if studentCell.find(label: student.name).isVisible {
                return studentCell
            }
        }
        return nil
    }
}
