//
//  AlertThreshold+Collections.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import CoreData
import SoPersistent
import SoLazy

extension AlertThreshold {
    static func studentPredicate(studentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "studentID", studentID)
    }
}

// ---------------------------------------------
// MARK: - Alerts collection for current observee
// ---------------------------------------------
extension AlertThreshold {
    public static func collectionOfAlertThresholds(session: Session, studentID: String) throws -> FetchedCollection<AlertThreshold> {
        let predicate = studentPredicate(studentID)
        let frc = AlertThreshold.fetchedResults(predicate, sortDescriptors: ["type".ascending], sectionNameKeypath: nil, inContext: try session.alertsManagedObjectContext())

        return try FetchedCollection<AlertThreshold>(frc: frc)
    }

    public static func refresher(session: Session) throws -> Refresher {
        let remote = try AlertThreshold.getAllAlertThresholds(session)
        let context = try session.alertsManagedObjectContext()
        let sync = AlertThreshold.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {

        private (set) public var collection: FetchedCollection<AlertThreshold>!

        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<AlertThreshold>, refresher: Refresher? = nil, viewModelFactory: AlertThreshold->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}