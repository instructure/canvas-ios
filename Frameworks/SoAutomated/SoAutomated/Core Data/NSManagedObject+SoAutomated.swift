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
import SoPersistent
import TooLegit

extension NSManagedObject {

    public var isValid: Bool {
        do {
            try self.validateForInsert()
            return true
        } catch {
            return false
        }
    }

    public static func factory(_ session: Session, options: [String: Any] = [:]) -> Self {
        let context = session.managedObjectContext(self, options: options)
        let entityName = self.entityName(context)
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let me = self.init(entity: entity, insertInto: context)
        addDefaultValues(me, context: context)
        try! context.saveFRD()
        return me
    }

    static func addDefaultValues(_ object: NSManagedObject, context: NSManagedObjectContext) {
        let entities = [object.entity, object.entity.superentity].flatMap { $0 }
        for entity in entities {
            for property in entity.properties {
                guard !property.isOptional else {
                    continue
                }

                guard let attribute = entity.attributesByName[property.name], attribute.defaultValue == nil else {
                    continue
                }

                guard let defaultValue = self.defaultValue(property.name, attributeType: attribute.attributeType, context: context) else {
                    fatalError("Override defaultValue(propertyName:attributeType) and provide a default value for \(property.name)")
                }

                object.setValue(defaultValue, forKey: property.name)
            }
        }
    }

    static func defaultValue(_ propertyName: String, attributeType: NSAttributeType, context: NSManagedObjectContext) -> Any? {
        switch attributeType {
        case .stringAttributeType:
            return ""
        case .booleanAttributeType:
            return false
        case .integer16AttributeType, .integer32AttributeType, .integer64AttributeType:
            return 1
        case .dateAttributeType:
            return Date()
        case .doubleAttributeType, .decimalAttributeType, .floatAttributeType:
            return 1.0
        case .binaryDataAttributeType:
            return Data()
        default:
            return nil
        }
    }

}

extension NSManagedObject {
    public static func count(inContext context: NSManagedObjectContext) -> Int {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName(context))
        return (try? context.count(for: fetch)) ?? -1
    }
}
