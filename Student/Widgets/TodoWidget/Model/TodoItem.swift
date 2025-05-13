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

/** Widgets need the Encodable protocol but since Color is not Encodable we store its hex value as a string. */
struct TodoItem: Hashable, Encodable, Identifiable {
    let id: ID
    let name: String
    let dueDate: Date
    let colorHex: String

    var color: Color {
        Color(hexString: colorHex) ?? .textDarkest
    }

    init(id: ID, name: String, dueDate: Date, color: UIColor) {
        self.id = id
        self.name = name
        self.dueDate = dueDate
        self.colorHex = color.hexString
    }
}

extension Array where Element == TodoItem {
    func sortedByDueDate() -> [Element] {
        sorted { $0.dueDate < $1.dueDate }
    }

    func itemDueOnSameDateAsPrevious(_ item: Element) -> Bool {
        guard let indexOfItem = firstIndex(of: item) else { return false }
        guard indexOfItem > 0 else { return false }
        let previousItem = self[indexOfItem - 1]
        let dateStringOfPrevious = previousItem.dueDate.formatted(.dateTime.year().month().day())
        let dateStringOfCurrent = item.dueDate.formatted(.dateTime.year().month().day())
        return dateStringOfCurrent == dateStringOfPrevious
    }

    func itemDueOnSameDateAsNext(_ item: Element) -> Bool {
        guard let indexOfItem = firstIndex(of: item) else { return false }
        guard count > indexOfItem + 1 else { return false }
        let nextItem = self[indexOfItem + 1]
        let dateStringOfNext = nextItem.dueDate.formatted(.dateTime.year().month().day())
        let dateStringOfCurrent = item.dueDate.formatted(.dateTime.year().month().day())
        return dateStringOfCurrent == dateStringOfNext
    }

    func firstN(_ n: Int) -> [Element] {
        guard count >= n else { return self }
        return Array(self[..<n])
    }

    var forMediumTodoScreen: [Element] {
        sortedByDueDate().firstN(2)
    }

    var forLargeTodoScreen: [Element] {
        sortedByDueDate().firstN(5)
    }
}
