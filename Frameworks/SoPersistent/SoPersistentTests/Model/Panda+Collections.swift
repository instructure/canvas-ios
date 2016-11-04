
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
import SoPersistent
import TooLegit
import CoreData

extension Panda {
    static func collectionByFirstLetterOfName(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let frc = Panda.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: "firstLetterOfName", inContext: context)
        let titleFunction: String?->String? = { $0.flatMap { "\($0.uppercaseString)" } }
        return try FetchedCollection<Panda>(frc: frc, titleForSectionTitle:titleFunction)
    }

    static func collection(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let frc = Panda.fetchedResults(nil, sortDescriptors: ["name".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection<Panda>(frc: frc)
    }

    static func pandasNamedPo(session: Session, inContext context: NSManagedObjectContext) throws -> FetchedCollection<Panda> {
        let predicate = NSPredicate(format: "%K == %@", "name", "Po")
        let frc = Panda.fetchedResults(predicate, sortDescriptors: ["id".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }
}
