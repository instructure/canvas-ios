//
//  Alert+Collections.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

extension Alert {
    public static func unreadPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == false", "read")
    }
    public static func undismissedPredicate() -> NSPredicate {
        return NSPredicate(format: "%K == false", "dismissed")
    }
    public static func observeePredicate(observeeID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "studentID", observeeID)
    }
}

// ---------------------------------------------
// MARK: - Alerts collection for current observee
// ---------------------------------------------
extension Alert {
    public static func collectionOfObserveeAlerts(session: Session, observeeID: String) throws -> FetchedCollection<Alert> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [Alert.undismissedPredicate(), Alert.observeePredicate(observeeID)])
        let frc = Alert.fetchedResults(predicate, sortDescriptors: ["actionDate".descending, "title".ascending], sectionNameKeypath: nil, inContext: try session.alertsManagedObjectContext())

        return try FetchedCollection<Alert>(frc: frc)
    }

    public static func refresher(session: Session, observeeID: String) throws -> Refresher {
        let predicate = Alert.observeePredicate(observeeID)
        let remote = try Alert.getObserveeAlerts(session, observeeID: observeeID)
        let context = try session.alertsManagedObjectContext()
        let sync = Alert.syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = self.cacheKey(context, [session.user.id, observeeID])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {

        private (set) public var collection: FetchedCollection<Alert>!

        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<Alert>, refresher: Refresher? = nil, viewModelFactory: Alert->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}