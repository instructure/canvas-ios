//
//  FetchedDetailsCollection.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/3/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import ReactiveCocoa

public class FetchedDetailsCollection<M, DVM where M: NSManagedObject, M: Model, DVM: Equatable>: Collection {
    public typealias Object = DVM

    var disposable: Disposable?
    let observer: ManagedObjectObserver<M>
    let detailsFactory: M->[DVM]
    var details: [DVM] = []
    public var collectionUpdated: [CollectionUpdate<DVM>] -> () = {_ in print("No one is watching...") }
    
    public init(observer: ManagedObjectObserver<M>, detailsFactory: M->[DVM]) {
        self.observer = observer
        self.detailsFactory = detailsFactory
        
        details = self.observer.object.map(detailsFactory) ?? []
        disposable = observer.signal
            .map { $0.1 }
            .observeOn(UIScheduler())
            .map { $0.map(detailsFactory) ?? [] }
            .observeNext { [weak self] deets in
                if let me = self {
                    let edits = me.details.distanceTo(deets)
                    me.details = deets
                    let updates: [CollectionUpdate<DVM>] = edits.map { edit in
                        switch edit {
                        case .Insert(let item, let index):
                            return .Inserted(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Replace(let item, let index):
                            return .Updated(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Delete(let item, let index):
                            return .Deleted(NSIndexPath(forRow: index, inSection: 0), item)
                        case .Move(let item, let fromIndex, let toIndex):
                            return .Moved(NSIndexPath(forRow: fromIndex, inSection: 0), NSIndexPath(forRow: toIndex, inSection: 0), item)
                        }
                    }
                    me.collectionUpdated(updates)
                }
            }
    }
    
    // keeping it simple... 1 section
    public func numberOfSections() -> Int {
        return 1
    }
    
    public func titleForSection(section: Int) -> String? {
        return nil
    }
    
    public func numberOfItemsInSection(section: Int) -> Int {
        return details.count
    }
    
    public subscript(indexPath: NSIndexPath) -> DVM {
        return details[indexPath.row]
    }
}

