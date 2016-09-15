//
//  Tab+Collections.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 3/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import SoPersistent
import TooLegit

extension Tab {
    
    public static func collection(session: Session, contextID: ContextID) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %K == NO", "rawContextID", contextID.canvasContextID, "hidden")
        let context = try session.enrollmentManagedObjectContext()
        let frc = Tab.fetchedResults(predicate, sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)

        return try FetchedCollection(frc: frc)
    }
    
    public static func shortcuts(session: Session, contextID: ContextID) throws -> FetchedCollection<Tab> {
        let predicate = NSPredicate(format: "%K == %@ AND %@ CONTAINS %K", "rawContextID", contextID.canvasContextID, ShortcutTabIDs, "id")
        let context = try session.enrollmentManagedObjectContext()
        let frc = Tab.fetchedResults(predicate, sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        
        return try FetchedCollection(frc: frc)
    }
    
    public static func refresher(session: Session, contextID: ContextID) throws -> Refresher {
        
        let remote = Tab.get(session, contextID: contextID)
        let context = try session.enrollmentManagedObjectContext()
        let predicate = NSPredicate(format: "%K == %@", "rawContextID", contextID.canvasContextID)
        let sync = syncSignalProducer(predicate, inContext: context, fetchRemote: remote)

        let key = cacheKey(context, [contextID.description])
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {
        
        private (set) public var collection: FetchedCollection<Tab>!
        
        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<Tab>, refresher: Refresher? = nil, viewModelFactory: Tab->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}