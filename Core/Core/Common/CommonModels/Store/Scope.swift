//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import Foundation

public struct Scope: Equatable {
    public let predicate: NSPredicate
    public let order: [NSSortDescriptor]
    public let sectionNameKeyPath: String?

    public init(predicate: NSPredicate, order: [NSSortDescriptor], sectionNameKeyPath: String? = nil) {
        self.predicate = predicate
        self.order = order
        self.sectionNameKeyPath = sectionNameKeyPath
    }

    public init(predicate: NSPredicate, orderBy order: String, ascending: Bool = true, naturally: Bool = false, sectionNameKeyPath: String? = nil) {
        let sort = NSSortDescriptor(key: order, ascending: ascending, naturally: naturally)
        self.init(predicate: predicate, order: [sort], sectionNameKeyPath: sectionNameKeyPath)
    }

    /// Returns a scope where all `key`s match `value`
    /// Adds a default `order` using the `key` ascending
    public static func `where`(_ key: String, equals value: Any?, orderBy order: String? = nil, ascending: Bool = true, naturally: Bool = false) -> Scope {
        let predicate: NSPredicate
        if let value = value {
            predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        } else {
            predicate = NSPredicate(format: "%K == nil", key)
        }
        let sort = NSSortDescriptor(key: order ?? key, ascending: ascending, naturally: naturally)
        return Scope(predicate: predicate, order: [sort])
    }

    /// Returns a scope where all `key`s match `value`
    public static func `where`(_ key: String, equals value: Any?, sortDescriptors: [NSSortDescriptor]) -> Scope {
        let predicate: NSPredicate
        if let value = value {
            predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        } else {
            predicate = NSPredicate(format: "%K == nil", key)
        }
        return Scope(predicate: predicate, order: sortDescriptors)
    }

    public static func all(orderBy order: String = "objectID", ascending: Bool = true, naturally: Bool = false) -> Scope {
        let sort = NSSortDescriptor(key: order, ascending: ascending, naturally: naturally)
        return Scope(predicate: .all, order: [sort])
    }

    public static var all: Scope { all() }
}

extension NSSortDescriptor {
    convenience init(key: String?, ascending: Bool = true, naturally: Bool) {
        self.init(key: key, ascending: ascending, selector: naturally ? #selector(NSString.localizedStandardCompare(_:)) : nil)
    }
}
