//
//  Module+Details.swift
//  SoEdventurous
//
//  Created by Nathan Armstrong on 9/21/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent
import TooLegit
import ReactiveCocoa
import SoPersistent
import CoreData

extension Module {
    public static func observer(session: Session, moduleID: String) throws -> ManagedObjectObserver<Module> {
        let context = try session.soEdventurousManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "id", moduleID)
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }

    public static func refresher(session: Session, courseID: String, moduleID: String) throws -> Refresher {
        let context = try session.soEdventurousManagedObjectContext()

        // Refresh all modules because prerequisite modules.
        let modules = try Module.getModules(session, courseID: courseID)
        let syncModules = Module.syncSignalProducer(inContext: context, fetchRemote: modules)

        let moduleItems = try ModuleItem.getModuleItems(session, courseID: courseID, moduleID: moduleID)
        let syncModuleItems = ModuleItem.syncSignalProducer(ModuleItem.predicate(forItemsIn: moduleID), includeSubentities: false, inContext: context, fetchRemote: moduleItems)

        let sync: SignalProducer<SignalProducer<Void, NSError>, NSError> = SignalProducer(values: [syncModules.map { _ in () }, syncModuleItems.map { _ in () }])

        let key = cacheKey(context, [courseID, moduleID])

        return SignalProducerRefresher(refreshSignalProducer: sync.flatten(.Merge), scope: session.refreshScope, cacheKey: key)
    }
}
