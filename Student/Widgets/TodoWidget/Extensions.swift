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

extension TimeInterval {
    static let widgetRefresh: TimeInterval = 7200 // 2 hours
}

extension Array where Element == TodoItem {

    func itemDueOnSameDateAsPrevious(_ item: Element) -> Bool {
        guard
            let indexOfItem = firstIndex(of: item),
            indexOfItem > startIndex
        else { return false }

        let previousItem = self[indexOfItem - 1]
        return previousItem.date.startOfDay() == item.date.startOfDay()
    }

    func itemDueOnSameDateAsNext(_ item: Element) -> Bool {
        guard
            let indexOfItem = firstIndex(of: item),
            indexOfItem < index(before: endIndex)
        else { return false }
        
        let nextItem = self[indexOfItem + 1]
        return nextItem.date.startOfDay() == item.date.startOfDay()
    }
}
