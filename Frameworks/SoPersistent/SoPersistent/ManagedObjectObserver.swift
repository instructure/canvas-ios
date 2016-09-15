//
//  ManagedObjectObserver.swift
//  SoPersistent
//
//  Created by Nathan Lambson on 2/2/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public enum ChangeType {
    case Delete
    case Update
}

public final class ManagedObjectObserver<M: NSManagedObject> {
    
    public init?(object: M, changeHandler: ChangeType -> ()) {
        guard let managedObjectContext = object.managedObjectContext else { return nil }

        token = managedObjectContext.addObjectsDidChangeNotificationObserver {
            [unowned self] note in
            guard let changedType = self.changeTypeOfObject(object, inNotification: note) else {
                return
            }
            
            self.objectHasBeenDeleted = changedType == .Delete
            changeHandler(changedType)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(token)
    }
    
    private var token: NSObjectProtocol!
    private var objectHasBeenDeleted: Bool = false
    
    private func changeTypeOfObject(object: M, inNotification note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.contains({ $0 === object }) {
            return .Delete
        }
        
        let updated = note.updatedObjects.union(note.refreshedObjects)
        if updated.contains({ $0 === object }) {
            return .Update
        }
        
        return nil
    }
}