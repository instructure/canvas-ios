//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public enum TodoWidgetEventNames: String {
    case active = "widget_todo_active"
    case deleted = "widget_todo_deleted"
    case create = "widget_todo_create_action"
    case openItem = "widget_todo_open_item_action"
    case openTodos = "widget_todo_open_todos_action"
    case refresh = "widget_todo_refresh_action"
}

public enum GradeListWidgetEventNames: String {
    case active = "widget_grade_list_active"
    case openGrades = "widget_grade_list_open_grades_action"
}

public enum CourseGradeWidgetEventNames: String {
    case openGrades = "widget_course_grade_open_grades_action"
    case active = "widget_course_grade_active"
}
