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

extension NSPredicate {
    public static var all: NSPredicate {
        return NSPredicate(value: true)
    }

    public static func id(_ id: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public convenience init(key: String, equals value: CVarArg?) {
        if let value {
            self.init(format: "%K == %@", argumentArray: [key, value])
        } else {
            self.init(format: "%K == nil", key)
        }
    }

    /// The stricter `KeyPath` type of `ReferenceWritableKeyPath` is needed, otherwise nonconforming `KeyPath`s would cause runtime crash.
    /// - Note: If the compiler doesn't allow this to be used in tests for example,
    /// that's probably because the property has private _write_ access level.
    public convenience init<Root, Value>(_ keyPath: ReferenceWritableKeyPath<Root, Value>, equals value: CVarArg?) {
        self.init(key: keyPath.string, equals: value)
    }

    /**
     - parameters:
        - predicate: The predicate to be combined with `self` using the logical AND operation.
     - returns: A new predicate by combining `self` and the `predicate` received as parameter with the logical AND operation.
     */
    public func and(_ predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(andPredicateWithSubpredicates: [self, predicate])
    }

    /**
     - parameters:
        - predicate: The predicate to be combined with `self` using the logical OR operation.
     - returns: A new predicate by combining `self` and the `predicate` received as parameter with the logical OR operation.
     */
    public func or(_ predicate: NSPredicate) -> NSPredicate {
        NSCompoundPredicate(orPredicateWithSubpredicates: [self, predicate])
    }
}
