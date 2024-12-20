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

    public func first<T>(where key: String, equals value: CVarArg?) -> T? {
        return all(where: key, equals: value).first
    }

    public func first<T>(scope: Scope) -> T? {
        fetch(scope: scope).first
    }

    public func all<T>(where key: String, equals value: CVarArg?) -> [T] {
        let predicate = NSPredicate(key: key, equals: value)
        return fetch(predicate)
    }

    public func count<T>(_ type: T.Type, where key: String, equals value: CVarArg?) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: T.self))
        request.predicate = NSPredicate(key: key, equals: value)
        return (try? count(for: request)) ?? 0
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

    public func fetch<T>(scope: Scope) -> [T] {
        let name = String(describing: T.self)
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        request.predicate = scope.predicate
        request.sortDescriptors = scope.order
        return (try? fetch(request)) as? [T] ?? []
    }

    public func delete<T: NSManagedObject>(_ objects: [T]) {
        for o in objects {
            delete(o)
        }
    }

    public func isObjectDeleted(_ object: NSManagedObject) -> Bool {
        if object.isDeleted || object.managedObjectContext == nil {
            return true
        }
        do {
            _ = try existingObject(with: object.objectID)
            return false
        } catch {
            return (error as NSError).code == NSManagedObjectReferentialIntegrityError
        }
    }

    public func copy<T: NSManagedObject>(_ original: T) -> T {
        let copy: T = insert()
        copy.setValuesForKeys(original.dictionaryWithValues(forKeys:
            original.entity.attributesByName.keys.map { $0 }
        ))
        return copy
    }

    public func saveAndNotify() throws {
        try save()
        InterprocessNotificationCenter.shared.post(name: NSPersistentStore.InterProcessNotifications.didWriteLocally)
    }

    /** This method force fetches all objects ignoring any cached data on the context. */
    public func forceRefreshAllObjects() {
        stalenessInterval = 0
        refreshAllObjects()
        stalenessInterval = -1
    }
}
