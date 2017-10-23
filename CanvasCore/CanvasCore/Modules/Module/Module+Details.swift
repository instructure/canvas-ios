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



import ReactiveSwift

import CoreData

extension Module {
    public static func detailsCacheKey(context: NSManagedObjectContext, courseID: String, moduleID: String) -> String {
        return cacheKey(context, [courseID, moduleID])
    }

    public static func observer(session: Session, moduleID: String) throws -> ManagedObjectObserver<Module> {
        let context = try session.soEdventurousManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "id", moduleID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }

    public static func detailSyncSignalProducer(session: Session, courseID: String, moduleID: String) throws -> SignalProducer<Void, NSError> {
        let context = try session.soEdventurousManagedObjectContext()

        // Refresh all modules because prerequisite modules.
        let modules = try Module.getModules(session, courseID: courseID)
        let localModules = Module.predicate(forModulesIn: courseID)
        let syncModules = Module.syncSignalProducer(localModules, inContext: context, fetchRemote: modules)

        let moduleItems = try ModuleItem.getModuleItems(session, courseID: courseID, moduleID: moduleID)
        let syncModuleItems = ModuleItem.syncSignalProducer(ModuleItem.predicate(forItemsIn: moduleID), includeSubentities: false, inContext: context, fetchRemote: moduleItems)

        let sync: SignalProducer<SignalProducer<Void, NSError>, NSError> = SignalProducer([syncModules.map { _ in () }, syncModuleItems.map { _ in () }])
        return sync.flatten(.merge)
    }

    public static func refresher(session: Session, courseID: String, moduleID: String) throws -> Refresher {
        let context = try session.soEdventurousManagedObjectContext()
        let sync = try detailSyncSignalProducer(session: session, courseID: courseID, moduleID: moduleID)
        let key = detailsCacheKey(context: context, courseID: courseID, moduleID: moduleID)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }
}
