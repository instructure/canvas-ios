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
