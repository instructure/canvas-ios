//
//  User+Collections.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension User {
    public static func collectionOfObservedUsers(session: Session) throws -> FetchedCollection<User> {
        let frc = User.fetchedResults(nil, sortDescriptors: ["sortableName".ascending], sectionNameKeypath: nil, inContext: try session.observeesManagedObjectContext())

        return try FetchedCollection<User>(frc: frc)
    }

    public static func observeesSyncProducer(session: Session) throws -> User.ModelPageSignalProducer {
        let remote = try User.getObserveeUsers(session)
        return User.syncSignalProducer(inContext: try session.observeesManagedObjectContext(), fetchRemote: remote)
    }

    public static func observeesRefresher(session: Session) throws -> Refresher {
        let sync = try User.observeesSyncProducer(session)
        let key = cacheKey(try session.observeesManagedObjectContext())
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public typealias TableViewController = FetchedTableViewController<User>
}
