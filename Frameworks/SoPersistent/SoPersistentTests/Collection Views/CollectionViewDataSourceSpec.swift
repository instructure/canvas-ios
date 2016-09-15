//
//  CollectionViewDataSourceSpec.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 8/22/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import SoPersistent
import XCTest
import SoAutomated
import CoreData
import Nimble

class CollectionViewDataSourceTests: XCTestCase {
    var managedObjectContext: NSManagedObjectContext!
    var collectionViewDataSource: CollectionCollectionViewDataSource<FetchedCollection<Panda>, CollectionViewCellViewModelFactory<Panda>>!

    override func tearDown() {
        managedObjectContext = nil
        collectionViewDataSource = nil
        super.tearDown()
    }

    func testProcessUpdates_removesItems() {
        pandasNamedPo()
        let controller = UICollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let collectionView = controller.collectionView!
        collectionViewDataSource.viewDidLoad(controller)

        let newPanda = Panda.build(managedObjectContext, id: "4", name: "Po")
        waitUntil { done in
            if collectionView.numberOfItemsInSection(0) == 4 { done() }
        }

        newPanda.name = "not po"
        managedObjectContext.processPendingChanges()

        expect(collectionView.numberOfItemsInSection(0)).toEventually(equal(3), timeout: 5)
    }

    func pandasNamedPo() {
        let user = User(credentials: .user1)
        managedObjectContext = try! user.session.soPersistentTestsManagedObjectContext()
        Panda.build(managedObjectContext, id: "1", name: "Po")
        Panda.build(managedObjectContext, id: "3", name: "Po")
        Panda.build(managedObjectContext, id: "5", name: "Po")
        let collection = try! Panda.pandasNamedPo(user.session, inContext: managedObjectContext)
        collectionViewDataSource = CollectionCollectionViewDataSource(collection: collection, viewModelFactory: CollectionViewCellViewModelFactory.empty)
    }
}
