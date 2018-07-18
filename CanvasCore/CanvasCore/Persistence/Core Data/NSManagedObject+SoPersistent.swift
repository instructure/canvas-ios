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
