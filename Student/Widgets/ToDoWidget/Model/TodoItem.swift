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

import Core
import SwiftUI
import WidgetKit

struct TodoItem: Hashable, Encodable {
    let name: String
    let dueAt: Date?
    let colorHex: String
    let route: URL

    var dueText: String {
        guard let dueAt else {
            return String(localized: "No Due Date", bundle: .core)
        }
        let format = String(localized: "Due %@", bundle: .core)
        return String.localizedStringWithFormat(format, dueAt.relativeDateTimeString)
    }

    var color: Color {
        Color(hexString: colorHex) ?? .textDarkest
    }

    init(todo: Todo, color: UIColor) {
        self.name = todo.name ?? ""
        self.dueAt = todo.dueAt
        self.colorHex = todo.contextColor?.hexString ?? Color.textDarkest.hexString
        self.route = todo.assignment?.route ?? URL(string: "canvas-course://")!
    }

    init(todo: Todo, color: Color) {
        self.init(todo: todo, color: UIColor(color))
    }

    init(todo: Todo) {
        self.name = todo.name ?? ""
        self.dueAt = todo.dueAt
        self.colorHex = todo.contextColor?.hexString ?? UIColor.course1.hexString
        self.route = todo.assignment?.route ?? URL(string: "canvas-course://")!
    }

    init(
        name: String = "Test To-do",
        dueAt: Date? = Date().addDays(5),
        color: Color = .textDarkest,
        route: URL = URL(string: "canvas-course://")!
    ) {
        self.name = name
        self.dueAt = dueAt
        self.colorHex = UIColor(color).hexString
        self.route = route
    }
}
