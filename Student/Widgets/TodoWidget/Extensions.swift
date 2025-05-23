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
import Foundation

extension Array where Element == Plannable {
    func sortedByDueDate() -> [Element] {
        sorted { $0.date ?? Date.distantFuture < $1.date ?? Date.distantFuture }
    }

    func itemDueOnSameDateAsPrevious(_ item: Element) -> Bool {
        guard let indexOfItem = firstIndex(of: item) else { return false }
        guard indexOfItem > 0 else { return false }
        guard let itemDate = item.date else { return false }
        let previousItem = self[indexOfItem - 1]
        guard let previousItemDate = previousItem.date else { return false }
        let dateStringOfPrevious = previousItemDate.formatted(.dateTime.year().month().day())
        let dateStringOfCurrent = itemDate.formatted(.dateTime.year().month().day())
        return dateStringOfCurrent == dateStringOfPrevious
    }

    func itemDueOnSameDateAsNext(_ item: Element) -> Bool {
        guard let indexOfItem = firstIndex(of: item) else { return false }
        guard count > indexOfItem + 1 else { return false }
        guard let itemDate = item.date else { return false }
        let nextItem = self[indexOfItem + 1]
        guard let nextItemDate = nextItem.date else { return false }
        let dateStringOfNext = nextItemDate.formatted(.dateTime.year().month().day())
        let dateStringOfCurrent = itemDate.formatted(.dateTime.year().month().day())
        return dateStringOfCurrent == dateStringOfNext
    }

    func firstN(_ n: Int) -> [Element] {
        guard count >= n else { return self }
        return Array(self[..<n])
    }
}
