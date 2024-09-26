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
        guard index < count else {
            return nil
        }
        return self[index]
    }

    var nilIfEmpty: Self? { isEmpty ? nil : self }
}

extension Array where Element: UIBarButtonItem {
    func removeDuplicates() -> [Element] {
        return reduce([]) { result, element in
            result.contains { $0.action == element.action } ? result : result + [element]
        }
    }
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
}

/// This property wrapper stores an array of objects as weak references.
@propertyWrapper
public struct WeakArray<Element> where Element: AnyObject {
    public var wrappedValue: [Element] {
        get {
            weakObjects.compactMap { $0.value }
        }
        set {
            weakObjects = newValue.map { WeakObject($0) }
        }
    }

    private var weakObjects: [WeakObject<Element>] = []

    public init() {}
}
