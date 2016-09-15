//
//  Assignment+Details.swift
//  Assignments
//
//  Created by Derrick Hathaway on 3/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import SoPersistent
import CoreData
import ReactiveCocoa


extension Assignment {
    
    public static func detailsCacheKey(context: NSManagedObjectContext, courseID: String, id: String) -> String {
        return cacheKey(context, [courseID, id])
    }
    
    public static func predicate(courseID: String, assignmentID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@ && %K == %@", "courseID", courseID, "id", assignmentID)
    }
    
    public static func refresher(session: Session, courseID: String, assignmentID: String) throws -> Refresher {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        let key = detailsCacheKey(context, courseID: courseID, id: assignmentID)
        let sync = Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public static func observer(session: Session, courseID: String, assignmentID: String) throws -> ManagedObjectObserver<Assignment> {
        let pred = predicate(courseID, assignmentID: assignmentID)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver<Assignment>(predicate: pred, inContext: context)
    }
    
    public static func refreshDetailsSignalProducer(session: Session, courseID: String, assignmentID: String) throws -> SignalProducer<[Assignment], NSError> {
        let context = try session.assignmentsManagedObjectContext()
        let remote = try Assignment.getAssignment(session, courseID: courseID, assignmentID: assignmentID).map { [$0] }
        let pred = predicate(courseID, assignmentID: assignmentID)
        
        return Assignment.syncSignalProducer(pred, inContext: context, fetchRemote: remote)     }
    
    public static func detailsTableViewDataSource<DVM: TableViewCellViewModel where DVM: Equatable>(session: Session, courseID: String, assignmentID: String, detailsFactory: Assignment->[DVM]) throws -> TableViewDataSource {
        let obs = try observer(session, courseID: courseID, assignmentID: assignmentID)
        let collection = FetchedDetailsCollection<Assignment, DVM>(observer: obs, detailsFactory: detailsFactory)
        return CollectionTableViewDataSource(collection: collection, viewModelFactory: { $0 })
    }
    
    public class DetailViewController: SoPersistent.TableViewController {
        private (set) public var observer: ManagedObjectObserver<Assignment>!
        
        public func prepare<DVM: TableViewCellViewModel where DVM: Equatable>(observer: ManagedObjectObserver<Assignment>, refresher: Refresher? = nil, detailsFactory: Assignment->[DVM]) {
            self.observer = observer
            let details = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: details)
        }
    }
}