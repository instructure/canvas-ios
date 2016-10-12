//
//  NSManagedObject+TableViewController.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 10/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData

public class FetchedTableViewController<M: NSManagedObject>: SoPersistent.TableViewController {
    
    private (set) public var collection: FetchedCollection<M>!
    
    public override init() {
        super.init()
    }
    
    public func prepare<VM: TableViewCellViewModel>(collection: FetchedCollection<M>, refresher: Refresher? = nil, viewModelFactory: M->VM) {
        self.collection = collection
        self.refresher = refresher
        self.dataSource = CollectionTableViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
    }
}
