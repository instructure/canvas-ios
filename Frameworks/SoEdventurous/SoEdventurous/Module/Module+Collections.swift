
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

extension Module {
    public static func predicate(forModulesIn courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    public static func allModulesCollection(session: Session, courseID: String) throws -> FetchedCollection<Module> {
        let context = try session.soEdventurousManagedObjectContext()
        let frc = Module.fetchedResults(predicate(forModulesIn: courseID), sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session, courseID: String) throws -> Refresher {
        let remote = try Module.getModules(session, courseID: courseID)
        let context = try session.soEdventurousManagedObjectContext()
        let sync = Module.syncSignalProducer(inContext: context, fetchRemote: remote) { module, _ in
            module.courseID = courseID
        }

        let key = cacheKey(context)

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<Module>
}
