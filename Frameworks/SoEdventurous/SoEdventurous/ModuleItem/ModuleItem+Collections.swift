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

extension ModuleItem {
    public static func predicate(forItemsIn moduleID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "moduleID", moduleID)
    }

    public static func predicateWithCompletionRequirement() -> NSPredicate {
        return NSPredicate(format: "%K != nil && %K != %@", "completionRequirement", "completionRequirement", ModuleItem.CompletionRequirement.MustChoose.rawValue)
    }

    public static func allModuleItemsCollection<T>(session: Session, moduleID: String, titleForSectionTitle: String? -> String? = { _ in nil }) throws -> FetchedCollection<T> {
        let context = try session.soEdventurousManagedObjectContext()
        let frc = fetchedResults(predicate(forItemsIn: moduleID), sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc, titleForSectionTitle: titleForSectionTitle)
    }

    public static func withCompletionRequirement(session: Session, moduleID: String) throws -> [ModuleItem] {
        let predicate = NSPredicate(format: "%K == %@, %K != nil && %K != %@", "moduleID", moduleID, "completionRequirement", "completionRequirement", ModuleItem.CompletionRequirement.MustChoose.rawValue)
        return try session.soEdventurousManagedObjectContext().findAll(matchingPredicate: predicate)
    }
}
