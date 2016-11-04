
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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