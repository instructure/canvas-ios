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

import CoreData

public extension NSManagedObjectContext {

    func fetchFirstOrInsert<T: NSManagedObject>(
        _ idKey: KeyPath<T, String>,
        equals value: String
    ) -> T {
        let keyPath = NSExpression(forKeyPath: idKey).keyPath
        let obj: T = first(scope: .where(keyPath, equals: value)) ?? T(context: self)
        obj.setValue(value, forKeyPath: keyPath)
        return obj
    }

    func object<T: NSManagedObject>(
        of idKey: KeyPath<T, String>,
        equals value: String
    ) -> T? {
        let keyPath = NSExpression(forKeyPath: idKey).keyPath
        return first(scope: .where(keyPath, equals: value))
    }
}
