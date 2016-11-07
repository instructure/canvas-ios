//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
