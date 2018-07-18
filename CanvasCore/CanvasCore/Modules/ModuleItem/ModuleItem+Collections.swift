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
    public static func predicate(forItemsIn moduleID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "moduleID", moduleID)
    }

    public static func predicateWithCompletionRequirement() -> NSPredicate {
        return NSPredicate(format: "%K != nil && %K != %@", "completionRequirement", "completionRequirement", ModuleItem.CompletionRequirement.mustChoose.rawValue)
    }

    public static func allModuleItemsCollection<T>(_ session: Session, moduleID: String, titleForSectionTitle: @escaping (String?) -> String? = { _ in nil }) throws -> FetchedCollection<T> {
        let context = try session.soEdventurousManagedObjectContext()
        return try FetchedCollection(frc: context.fetchedResults(predicate(forItemsIn: moduleID), sortDescriptors: ["position".ascending]), titleForSectionTitle: titleForSectionTitle)
    }

    public static func withCompletionRequirement(_ session: Session, moduleID: String) throws -> [ModuleItem] {
        let predicate = NSPredicate(format: "%K == %@, %K != nil && %K != %@", "moduleID", moduleID, "completionRequirement", "completionRequirement", ModuleItem.CompletionRequirement.mustChoose.rawValue)
        return try session.soEdventurousManagedObjectContext().findAll(matchingPredicate: predicate)
    }
}
