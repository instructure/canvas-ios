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
import Marshal
import ReactiveSwift


private let errorDesc = NSLocalizedString("There was a problem reading cached data", tableName: "Localizable", bundle: .core, value: "", comment: "Persistence error message")
private let errorTitle = NSLocalizedString("Read Error", tableName: "Localizable", bundle: .core, value: "", comment: "tile for error reading cache")

extension NSManagedObject {
    public convenience init(inContext context: NSManagedObjectContext) {
        let entityName = type(of: self).entityName(context)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        self.init(entity: entity, insertInto: context)
    }

    public static func create<T>(inContext context: NSManagedObjectContext) -> T {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: entityName(context), into: context) as? T else { ❨╯°□°❩╯⌢"This only works with managed objects" }
        return entity
    }

    public static func entityName(_ context: NSManagedObjectContext) -> String {
        let className = NSStringFromClass(object_getClass(self))
        guard let entityName = className.components(separatedBy: ".").last else { ❨╯°□°❩╯⌢"ObjC runtime has failed us. Just give up and go home." }
        
        let model = context.persistentStoreCoordinatorFRD.managedObjectModel
        if let _ = model.entitiesByName[className] {
            return className
        } else if let _ = model.entitiesByName[entityName] {
            return entityName
        } else {
            ❨╯°□°❩╯⌢"Did you give your entity a class name? Do they match? Check again."
        }
    }

    public func delete(inContext context: NSManagedObjectContext) {
        context.delete(self)
    }
}
