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


extension ModuleItem {
    public func next(_ session: Session) throws -> ModuleItem? {
        return try search(session, ascending: true)
    }

    public func previous(_ session: Session) throws -> ModuleItem? {
        return try search(session, ascending: false)
    }

    fileprivate func search(_ session: Session, ascending: Bool) throws -> ModuleItem? {
        let context = try session.soEdventurousManagedObjectContext()

        let higherPosition = NSPredicate(format: "%K > %f", "position", position)
        let lowerPosition = NSPredicate(format: "%K < %f", "position", position)
        let searchPosition = ascending ? higherPosition : lowerPosition
        let sameModule = ModuleItem.predicate(forItemsIn: moduleID)
        let notASubHeader = NSPredicate(format: "%K != %@", "contentType", ModuleItem.ContentType.subHeader.rawValue)
        let unLocked = NSPredicate(format: "%K != %@ || %K == %@", "lockedForUser", NSNumber(value: true), "contentType", ContentType.assignment.rawValue)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [sameModule, searchPosition, notASubHeader, unLocked])

        let sort = ascending ? "position".ascending : "position".descending

        let fetch: NSFetchRequest<ModuleItem> = context.fetch(predicate, sortDescriptors: [sort])
        let results: [ModuleItem] = try context.findAll(fromFetchRequest: fetch)
        return results.first
    }
}
