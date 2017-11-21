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
