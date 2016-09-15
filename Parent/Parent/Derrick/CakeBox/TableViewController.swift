//
//  TableViewController.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/29/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CoreData

public protocol TableViewCellViewModel {
    static func tableViewDidLoad(tableView: UITableView)
    func cellForTableView(tableView: UITableView, indexPath: NSIndexPath) -> UITableViewCell
}


public class TableViewController<Collection: ViewModelCollection, SyncSignalProducer: SignalProducerType where Collection.ViewModel: TableViewCellViewModel>: UITableViewController {
    public var collection: Collection {
        didSet {
            tableView.reloadData()
        }
    }
    
    let syncProducer: SyncSignalProducer
    var disposable: Disposable?
    
    public init(collection: Collection, syncProducer: SyncSignalProducer) {
        self.collection = collection
        self.syncProducer = syncProducer
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Collection.ViewModel.tableViewDidLoad(tableView)
        collection.collectionUpdated = { [weak self] updates in
            self?.handleUpdates(updates)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        refresh(nil)
    }
    
    func refresh(refreshContol: UIRefreshControl?) {
        disposable = syncProducer.start { event in
            switch event {
            case .Completed, .Interrupted, .Failed:
                refreshContol?.endRefreshing()
            default: break
            }
        }
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let vm = collection[indexPath]
        
        return vm.cellForTableView(tableView, indexPath: indexPath)
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return collection.numberOfSections
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }

    private func handleUpdates(updates: [CollectionUpdate]) {
        tableView.beginUpdates()
        for update in updates {
            switch update {
            case .SectionInserted(let s):
                tableView.insertSections(NSIndexSet(index: s), withRowAnimation: .Automatic)
            case .SectionDeleted(let s):
                tableView.deleteSections(NSIndexSet(index: s), withRowAnimation: .Automatic)
                
            case .Inserted(let indexPath):
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case .Updated(let indexPath):
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            case let .Moved(from, to):
                tableView.moveRowAtIndexPath(from, toIndexPath: to)
            case .Deleted(let indexPath):
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        tableView.endUpdates()
    }
}

import JaSON

extension SynchronizedModel where Self: NSManagedObject {
    public static func tableViewController<ViewModel: TableViewCellViewModel>(local: NSPredicate?, sortDescriptors: [NSSortDescriptor] = [], context: NSManagedObjectContext, remote: SignalProducer<JSONObject, NSError>, viewModelFactory: Self->ViewModel) throws -> UIViewController {

        let frc = Self.fetchedResults(local, sortDescriptors: sortDescriptors, inContext: context)
        
        let collection = try FetchedCollection(frc: frc, viewModelFactory: viewModelFactory)
        
        let sync = Self.syncSignalProducer(Self.fetch(local, sortDescriptors: nil, inContext: context), inContext: context, fetchRemote: remote)
        
        return TableViewController(collection: collection, syncProducer: sync)
    }
}
