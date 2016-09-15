//
//  Todo+Collections.swift
//  Todo
//
//  Created by Brandon Pluim on 4/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import TooLegit
import CoreData
import SoPersistent
import SoLazy

// ---------------------------------------------
// MARK: - Calendar Events collection for current user
// ---------------------------------------------
extension Todo {

    public static func allTodos(session: Session) throws -> FetchedCollection<Todo> {
        let predicate = NSPredicate(format: "%K == false", "done")
        let frc = Todo.fetchedResults(predicate, sortDescriptors: ["assignmentDueDate".ascending, "assignmentName".ascending], sectionNameKeypath: nil, inContext: try session.todosManagedObjectContext())
        return try FetchedCollection(frc: frc)
    }

    public static func refresher(session: Session) throws -> Refresher {
        let remote = try Todo.getTodos(session)
        let context = try session.todosManagedObjectContext()
        let sync = Todo.syncSignalProducer(inContext: context, fetchRemote: remote)
        let key = cacheKey(context)
        return SignalProducerRefresher(refreshSignalProducer: sync, scope: session.refreshScope, cacheKey: key)
    }

    public class TableViewController: SoPersistent.TableViewController {

        private (set) public var collection: FetchedCollection<Todo>!

        public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<Todo>, refresher: Refresher? = nil, viewModelFactory: Todo->VM) {
            self.collection = collection
            self.refresher = refresher
            dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
        }
    }
}