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


import Marshal
import CoreData

extension ModuleItem {
    public static func detailsCacheKey(context: NSManagedObjectContext, courseID: String, moduleItemID: String) -> String {
        return cacheKey(context, [courseID, moduleItemID])
    }

    public static func observer(_ session: Session, moduleItemID: String) throws -> ManagedObjectObserver<ModuleItem> {
        let context = try session.soEdventurousManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "id", moduleItemID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }

    public static func refresher(session: Session, courseID: String, moduleItemID: String) throws -> Refresher {
        let context = try session.soEdventurousManagedObjectContext()

        let moduleID = try ModuleItem.moduleItemSequence(session, courseID: courseID, moduleItemID: moduleItemID)
            .flatMap(.latest) { json in
                return attemptProducer { () throws -> String? in
                    let items: [JSONObject] = try json <| "items"
                    guard let item = items.first else { return nil }
                    let current: JSONObject = try item <| "current"
                    return try current.stringID("module_id")
                }
            }
            .skipNil()

        let sync = moduleID.flatMap(.latest) { moduleID in
            return attemptProducer {
                return try Module.detailSyncSignalProducer(session: session, courseID: courseID, moduleID: moduleID)
            }
        }
        .flatten(.latest)

        let key = detailsCacheKey(context: context, courseID: courseID, moduleItemID: moduleItemID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
