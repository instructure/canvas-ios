//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import CoreData

extension NSManagedObjectContext {
    public func insert<T>() -> T {
        let name = String(describing: T.self)
        if let result = NSEntityDescription.insertNewObject(forEntityName: name, into: self) as? T {
            return result
        } else {
            fatalError()
        }
    }

    public func first<T>(where key: String, equals value: CVarArg) -> T? {
        return all(where: key, equals: value).first
    }

    public func all<T>(where key: String, equals value: CVarArg) -> [T] {
        let predicate = NSPredicate(format: "%K == %@", key, value)
        return fetch(predicate)
    }

    public func refresh() {
        refreshAllObjects()
    }

    public func fetch<T>(_ predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let name = String(describing: T.self)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return (try? fetch(request)) as? [T] ?? []
    }

    public func delete<T: NSManagedObject>(_ objects: [T]) {
        for o in objects {
            delete(o)
        }
    }
}
