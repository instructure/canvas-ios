//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public extension Array {

    /**
     Appends the unwrapped value of the given `element` to the array.
     Does nothing if `element` is `nil`.
     */
    mutating func appendUnwrapped(_ element: Element?) {
        guard let element = element else { return }
        append(element)
    }

    subscript(safeIndex index: Int) -> Element? {
        guard index < count && index >= 0 else {
            return nil
        }
        return self[index]
    }

    var nilIfEmpty: Self? { isEmpty ? nil : self }
}

public extension Array where Element: Equatable {

    /// Appends element if not included in the array, otherwise it will remove
    /// all occurrences of it.
    mutating func appendOrRemove(_ element: Element) {
        if contains(element) {
            removeAll(where: { $0 == element })
        } else {
            append(element)
        }
    }

    func removingDuplicates() -> Self {
        var copy = [Element]()
        for element in self {
            if copy.contains(element) { continue }
            copy.append(element)
        }
        return copy
    }
}
