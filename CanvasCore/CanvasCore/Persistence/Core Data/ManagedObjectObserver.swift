//
// Copyright (C) 2016-present Instructure, Inc.
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
import CoreData

extension Notification {
    
    func objectsForKey(_ key: String) -> Set<NSManagedObject> {
        return (userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }
    
    public var insertedObjects: Set<NSManagedObject> {
        return objectsForKey(NSInsertedObjectsKey)
    }
    
    public var updatedObjects: Set<NSManagedObject> {
        return objectsForKey(NSUpdatedObjectsKey)
    }
    
    public var deletedObjects: Set<NSManagedObject> {
        return objectsForKey(NSDeletedObjectsKey)
    }
    
    public var refreshedObjects: Set<NSManagedObject> {
        return objectsForKey(NSRefreshedObjectsKey)
    }
    
    public var invalidatedObjects: Set<NSManagedObject> {
        return objectsForKey(NSInvalidatedObjectsKey)
    }
    
    public var invalidatedAllObjects: Bool {
        return userInfo?[NSInvalidatedAllObjectsKey] != nil
    }
}


public enum ManagedObjectChange {
    case insert
    case delete
    case update
}

import ReactiveSwift
import Result

public final class ManagedObjectObserver<Object: NSManagedObject> {
    
    fileprivate let predicate: NSPredicate
    fileprivate let context: NSManagedObjectContext
    fileprivate (set) public var object: Object?
    fileprivate let token: Lifetime.Token
    
    public let signal: Signal<(ManagedObjectChange, Object?), NoError>
    
    public init(predicate: NSPredicate, inContext context: NSManagedObjectContext) throws {
        self.predicate = predicate
        self.context = context

        let token = Lifetime.Token()
        self.signal = ManagedObjectObserver<Object>.changes(predicate: predicate, context: context).take(during: Lifetime(token))
        self.token = token

        let request: NSFetchRequest<Object> = context.fetch(predicate, sortDescriptors: nil)
        object = (try context.fetch(request)).first
    }
    
    public static func changes(predicate: NSPredicate, context: NSManagedObjectContext) -> Signal<(ManagedObjectChange, Object?), NoError> {
        return NotificationCenter
            .default
            .reactive
            .notifications(forName: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            .mapChanges(matching: predicate)
            .skipNil()
    }

    public static func object(predicate: NSPredicate, context: NSManagedObjectContext) -> Signal<Object, NoError> {
        return changes(predicate: predicate, context: context)
            .map { _, object in object }
            .skipNil()
    }

}

extension SignalProtocol where Value == Notification {
    public func mapChanges<Object>(matching predicate: NSPredicate) -> Signal<(ManagedObjectChange, Object?)?, Error> {
        return self.signal.map { note in
            if let inserted = note.insertedObjects.map({ $0 as? Object }).first(where: predicate.evaluate) {
                return (.insert, inserted)
            }

            if note.invalidatedAllObjects {
                return (.delete, nil)
            }

            if let deleted = note.deletedObjects.union(note.invalidatedObjects).map({ $0 as? Object }).first(where: predicate.evaluate) {
                return (.delete, deleted)
            }

            if let updated = note.updatedObjects.union(note.refreshedObjects).map({ $0 as? Object }).first(where: predicate.evaluate) {
                return (.update, updated)
            }

            return nil
        }
    }
}

extension SignalProducerProtocol where Value == Notification {
    public func mapChanges<Object>(matching predicate: NSPredicate) -> SignalProducer<(ManagedObjectChange, Object?)?, Error> {
        return self.lift { $0.mapChanges(matching: predicate) }
    }
}
