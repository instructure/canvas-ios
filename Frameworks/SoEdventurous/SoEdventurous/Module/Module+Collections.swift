//
//  Module+Collections.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
