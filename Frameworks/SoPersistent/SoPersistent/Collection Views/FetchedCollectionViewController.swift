//
//  FetchedCollectionViewController.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 10/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData


public class FetchedCollectionViewController<M: NSManagedObject>: CollectionViewController {
    
    private (set) public var collection: FetchedCollection<M>!
    
    public override init() {
        super.init()
    }
    
    public func prepare<VM: CollectionViewCellViewModel>(collection: FetchedCollection<M>, refresher: Refresher? = nil, viewModelFactory: M->VM) {
        self.collection = collection
        self.refresher = refresher
        dataSource = CollectionCollectionViewDataSource(collection: collection, viewModelFactory: viewModelFactory)
    }
}
