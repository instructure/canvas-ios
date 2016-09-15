//
//  ModuleItem+Collections.swift
//  SoEdventurous
//
//  Created by Ben Kraus on 9/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit

extension ModuleItem {
    public static func predicate(forItemsIn moduleID: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", "moduleID", moduleID)
    }
    
    public static func allModuleItemsCollection(session: Session, courseID: String, moduleID: String) throws -> FetchedCollection<ModuleItem> {
        let context = try session.soEdventurousManagedObjectContext()
        let frc = ModuleItem.fetchedResults(predicate(forItemsIn: moduleID), sortDescriptors: ["position".ascending], sectionNameKeypath: nil, inContext: context)
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session, courseID: String, moduleID: String) throws -> Refresher {
        let remote = try ModuleItem.getModuleItems(session, courseID: courseID, moduleID: moduleID)
        let context = try session.soEdventurousManagedObjectContext()
        let sync = ModuleItem.syncSignalProducer(inContext: context, fetchRemote: remote)

        let key = cacheKey(context)

        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {

        private (set) public var collection: FetchedCollection<ModuleItem>!

        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<ModuleItem>, refresher: Refresher? = nil, viewModelFactory: ModuleItem->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}