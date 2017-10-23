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
