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
