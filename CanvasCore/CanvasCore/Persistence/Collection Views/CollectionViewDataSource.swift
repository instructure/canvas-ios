//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

import UIKit


import ReactiveSwift

@objc
public protocol CollectionViewDataSource: UICollectionViewDataSource {
    func viewDidLoad(_ controller: UICollectionViewController)
    
    var layout: UICollectionViewLayout { get }
}

open class CollectionCollectionViewDataSource<C: Collection, VM: CollectionViewCellViewModel>: NSObject, CollectionViewDataSource {
    
    open let collection: C
    open let viewModelFactory: (C.Object)->VM
    fileprivate var disposable: Disposable?
    
    weak var collectionView: UICollectionView? {
        didSet {
            oldValue?.dataSource = nil
            collectionView?.dataSource = self
            collectionView?.reloadData()
        }
    }
    
    public init(collection: C, viewModelFactory: @escaping (C.Object) -> VM) {
        self.collection = collection
        self.viewModelFactory = viewModelFactory
        super.init()
        
        disposable = collection.collectionUpdates.observe(on: UIScheduler()).observeValues { [weak self] updates in
            self?.processUpdates(updates)
        }.map(ScopedDisposable.init)
    }
    
    
    open func viewDidLoad(_ controller: UICollectionViewController) {
        collectionView = controller.collectionView
        VM.viewDidLoad(collectionView!)
    }
    
    open var layout: UICollectionViewLayout {
        return VM.layout
    }
    
    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collection.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collection.numberOfItemsInSection(section)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let vm = viewModelFactory(collection[indexPath])
        let cell = vm.cellForCollectionView(collectionView, indexPath: indexPath)
        
        if let cardCell = cell as? PrettyCardsCell, let layout = collectionView.collectionViewLayout as? PrettyCardsLayout {
            cardCell.widthConstraint.constant = layout.estimatedItemSize.width
        }
        return cell
    }
    
    // MARK: CollectionUpdates
    func processUpdates(_ updates: [CollectionUpdate<C.Object>]) {
        guard let c = collectionView else { return }

        if updates == [.reload] || c.window == nil  {
            c.reloadData()
            c.collectionViewLayout.invalidateLayout()
            return
        }

        c.performBatchUpdates({
            for update in updates {
                switch update {
                case .sectionDeleted(let s):
                    c.deleteSections(IndexSet(integer: s))
                case .sectionInserted(let s):
                    c.insertSections(IndexSet(integer: s))
                    
                case .inserted(let indexPath, _, _):
                    c.insertItems(at: [indexPath])
                case .updated(let indexPath, _, _):
                    c.reloadItems(at: [indexPath])
                case let .moved(from, to, _, _):
                    c.moveItem(at: from, to: to)
                case .deleted(let indexPath, _, _):
                    c.deleteItems(at: [indexPath])
                    
                case .reload:
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
