//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData

public protocol Snapshot<Model>: Sendable where Model: NSManagedObject {
    associatedtype Model

    init(model: Model)
}

public protocol Detachable {
    associatedtype Snapshot: Snapshots.Snapshot
}

extension Detachable where Self == Snapshot.Model {
    public var snapshot: Snapshot { Snapshot(model: self) }
}

@dynamicMemberLookup
public protocol CustomSnapshot: Snapshot where Model: Detachable {
    var attributes: Model.Snapshot { get }

    subscript<T>(dynamicMember keyPath: KeyPath<Model.Snapshot, T>) -> T { get }
}

public extension CustomSnapshot {
    subscript<T>(dynamicMember keyPath: KeyPath<Model.Snapshot, T>) -> T {
        attributes[keyPath: keyPath]
    }
}

extension Array where Element: Detachable, Element == Element.Snapshot.Model {
    public func snapshots() -> [Element.Snapshot] { map(Element.Snapshot.init) }
}

extension Set where Element: Detachable, Element == Element.Snapshot.Model {
    public func snapshots() -> [Element.Snapshot] { map(Element.Snapshot.init) }
}
