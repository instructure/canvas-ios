//
//  CollectionViewDataSource.swift
//  SoPersistent
//
//  Created by Derrick Hathaway on 3/7/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import UIKit
import SoPretty

@objc
public protocol CollectionViewDataSource: NSObjectProtocol, UICollectionViewDataSource {
    func viewDidLoad(controller: UICollectionViewController)
    
    var layout: UICollectionViewLayout { get }
}

public class CollectionCollectionViewDataSource<C: Collection, VM: CollectionViewCellViewModel>: NSObject, CollectionViewDataSource {
    
    public let collection: C
    public let viewModelFactory: C.Object->VM
    
    weak var collectionView: UICollectionView? {
        didSet {
            oldValue?.dataSource = nil
            collectionView?.dataSource = self
            collectionView?.reloadData()
        }
    }
    
    public init(collection: C, viewModelFactory: C.Object -> VM) {
        self.collection = collection
        self.viewModelFactory = viewModelFactory
        super.init()
        
        collection.collectionUpdated = { [weak self] updates in
            self?.processUpdates(updates)
        }
    }
    
    
    public func viewDidLoad(controller: UICollectionViewController) {
        collectionView = controller.collectionView
        VM.viewDidLoad(collectionView!)
    }
    
    public var layout: UICollectionViewLayout {
        return VM.layout
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return collection.numberOfSections()
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let vm = viewModelFactory(collection[indexPath])
        let cell = vm.cellForCollectionView(collectionView, indexPath: indexPath)
        
        if let cardCell = cell as? PrettyCardsCell, layout = collectionView.collectionViewLayout as? PrettyCardsLayout {
            cardCell.widthConstraint.constant = layout.estimatedItemSize.width
        }
        return cell
    }
    
    // MARK: CollectionUpdates
    func processUpdates(updates: [CollectionUpdate<C.Object>]) {
        guard let c = collectionView else { return }

        if updates == [.Reload] || c.window == nil  {
            c.reloadData()
            return
        }

        c.performBatchUpdates({
            for update in updates {
                switch update {
                case .SectionDeleted(let s):
                    c.deleteSections(NSIndexSet(index: s))
                case .SectionInserted(let s):
                    c.insertSections(NSIndexSet(index: s))
                    
                case .Inserted(let indexPath, _):
                    c.insertItemsAtIndexPaths([indexPath])
                case .Updated(let indexPath, _):
                    c.reloadItemsAtIndexPaths([indexPath])
                case let .Moved(from, to, _):
                    c.moveItemAtIndexPath(from, toIndexPath: to)
                case .Deleted(let indexPath, _):
                    c.deleteItemsAtIndexPaths([indexPath])
                    
                case .Reload:
                    c.reloadData()
                }
            }
            }, completion: nil)
    }
}


extension CollectionTableViewDataSource where C.Object == VM {
    public convenience init(collection: C) {
        self.init(collection: collection, viewModelFactory: { $0 })
    }
}
