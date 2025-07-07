//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Core
import Foundation

extension Course {
    var route: URL {
        return .appRoute("courses/\(id)/grades")
    }
}

extension Assignment {
    var route: URL {
        return .appRoute("courses/\(courseID)/assignments/\(id)")
    }
}

extension TodoItem {
    var route: URL {
        var url = switch type {
        case .calendar_event:
            URL.todoWidgetRoute("todo-widget/calendar_events/\(id)")
        case .planner_note:
            URL.todoWidgetRoute("todo-widget/planner-notes/\(id)")
        default:
            htmlURL?.appendingOrigin("todo-widget") ?? .appEmptyRoute
        }

        if let dateString = date
            .formatted(.queryDayDateStyle)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            url.append(queryItems: [
                URLQueryItem(name: "todo_date", value: dateString)
            ])
        }

        return url
    }
}

extension URL {

    static var todoListRoute: URL {
        .todoWidgetRoute("todo-widget/planner-notes")
    }

    static var addTodoRoute: URL {
        .todoWidgetRoute("todo-widget/planner-notes/new")
    }

    static func calendarDayRoute(_ date: Date) -> URL {
        let dateString = date
            .formatted(.queryDayDateStyle)
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        return .todoWidgetRoute("todo-widget/calendar/\(dateString)")
    }
}
