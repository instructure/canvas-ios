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


import ReactiveCocoa

extension Module {
    public static func predicate(forModulesIn courseID: String) -> NSPredicate {
        return NSPredicate(format:"%K == %@", "courseID", courseID)
    }

    public static func predicate(withIDs ids: [String]) -> NSPredicate {
        return NSPredicate(format: "%K IN %@", "id", ids)
    }

    public static func predicate(withPrerequisite moduleID: String) -> NSPredicate {
        return NSPredicate(format: "%K CONTAINS %@", "prerequisiteModuleIDs", moduleID)
    }

    public static func collectionCacheKey(context: NSManagedObjectContext, courseID: String) -> String {
        return cacheKey(context, [courseID])
    }

    public static func collection<T>(session: Session, courseID: String, moduleIDs: [String]? = nil, titleForSectionTitle: @escaping (String?) -> String? = { _ in nil }) throws -> FetchedCollection<T> {
        let context = try session.soEdventurousManagedObjectContext()
        let pred = moduleIDs.flatMap { NSCompoundPredicate(andPredicateWithSubpredicates: [predicate(forModulesIn: courseID), predicate(withIDs: $0)]) } ?? predicate(forModulesIn: courseID)
        return try FetchedCollection(frc: context.fetchedResults(pred, sortDescriptors: ["position".ascending]), titleForSectionTitle: titleForSectionTitle)
    }

    public static func refresher(session: Session, courseID: String) throws -> Refresher {
        let context = try session.soEdventurousManagedObjectContext()
        let remote = try Module.getModules(session, courseID: courseID)
        let local = Module.predicate(forModulesIn: courseID)
        let sync = Module.syncSignalProducer(local, inContext: context, fetchRemote: remote)
        let key = collectionCacheKey(context: context, courseID: courseID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
