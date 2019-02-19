//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public struct Scope {
    public let predicate: NSPredicate
    public let order: [NSSortDescriptor]
    public let sectionNameKeyPath: String?

    public init(predicate: NSPredicate, order: [NSSortDescriptor], sectionNameKeyPath: String? = nil) {
        self.predicate = predicate
        self.order = order
        self.sectionNameKeyPath = sectionNameKeyPath
    }

    /// Returns a scope where all `key`s match `value`
    /// Adds a default `order` using the `key` ascending
    public static func `where`(_ key: String, equals value: Any, orderBy order: String? = nil, ascending: Bool = true, naturally: Bool = false) -> Scope {
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        let sort = NSSortDescriptor(key: order ?? key, ascending: ascending, selector: naturally ? #selector(NSString.localizedStandardCompare(_:)) : nil)
        return Scope(predicate: predicate, order: [sort])
    }

    public static func all(orderBy order: String, ascending: Bool = true, naturally: Bool = false) -> Scope {
        let sort = NSSortDescriptor(key: order, ascending: ascending, selector: naturally ? #selector(NSString.localizedStandardCompare(_:)) : nil)
        return Scope(predicate: .all, order: [sort])
    }
}

public protocol Scoped {
    associatedtype ScopeKeys
    static func scope(forName name: ScopeKeys) -> Scope
}
