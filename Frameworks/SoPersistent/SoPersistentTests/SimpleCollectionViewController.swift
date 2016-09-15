//
//  SimpleCollectionViewController.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoPersistent

class SimpleCollectionViewDataSource: NSObject, CollectionViewDataSource {
    var viewDidLoadWasCalled = false
    var layoutForTraitsWasCalled = false
    var sizeInCollectionViewWasCalled = false

    func viewDidLoad(controller: UICollectionViewController) {
        viewDidLoadWasCalled = true
    }

    var layout: UICollectionViewLayout {
        layoutForTraitsWasCalled = true
        return UICollectionViewFlowLayout()
    }

    func sizeInCollectionView(collectionView: UICollectionView, forItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        sizeInCollectionViewWasCalled = true
        return CGSizeZero
    }

    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func isEmpty() -> Bool {
        return true
    }

}
