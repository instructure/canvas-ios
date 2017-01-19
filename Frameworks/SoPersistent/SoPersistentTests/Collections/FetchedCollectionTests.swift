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
    
    

import XCTest
@testable import SoPersistent
import SoAutomated
import CoreData
import TooLegit

class FetchedCollectionTests: XCTestCase {
    func testDescribeFetchedCollection() {
        var session: Session!
        var managedObjectContext: NSManagedObjectContext!
        var collection: FetchedCollection<Panda>!

        var one: Panda!
        var two: Panda!
        var three: Panda!
        var four: Panda!

        let beforeEach: ()->Void = {
            session = .user1
            managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
            collection = try! Panda.collectionByFirstLetterOfName(session, inContext: managedObjectContext)

            one = Panda.build(managedObjectContext, name: "A")
            two = Panda.build(managedObjectContext, name: "B")
            three = Panda.build(managedObjectContext, name: "C")
            four = Panda.build(managedObjectContext, name: "Charlie")

        }

        describe("frc sections") {
            context("when there are sections") {
                beforeEach()
                let collection: FetchedCollection<Panda> = try! Panda.collectionByFirstLetterOfName(session, inContext: managedObjectContext)

                it("has the number of sections") {
                    XCTAssertEqual(3, collection.numberOfSections())
                }

                it("has the number of items in each section") {
                    XCTAssertEqual(1, collection.numberOfItemsInSection(0))
                    XCTAssertEqual(1, collection.numberOfItemsInSection(1))
                    XCTAssertEqual(2, collection.numberOfItemsInSection(2))
                }

                it("has section titles") {
                    XCTAssertEqual("A", collection.titleForSection(0))
                    XCTAssertEqual("B", collection.titleForSection(1))
                    XCTAssertEqual("C", collection.titleForSection(2))
                }

                it("has a subscript for accessing an object at an indexPath") {
                    XCTAssertEqual(one, collection[IndexPath(row: 0, section: 0)])
                    XCTAssertEqual(two, collection[IndexPath(row: 0, section: 1)])
                    XCTAssertEqual(three, collection[IndexPath(row: 0, section: 2)])
                    XCTAssertEqual(four, collection[IndexPath(row: 1, section: 2)])
                }
            }

            context("when sections are nil") {
                class FRC: NSFetchedResultsController<Panda> {
                    fileprivate override func performFetch() throws {
                        return // nil sections!
                    }
                }
                let frc = FRC(
                    fetchRequest: managedObjectContext.fetch(nil, sortDescriptors: ["name".ascending]),
                    managedObjectContext: managedObjectContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil)
                let collection = try! FetchedCollection<Panda>(frc: frc)

                it("defaults to 0 for number of sections") {
                    XCTAssertEqual(0, collection.numberOfSections())
                }

                it("defaults to 0 for number of items in any section") {
                    XCTAssertEqual(0, collection.numberOfItemsInSection(0))
                    XCTAssertEqual(0, collection.numberOfItemsInSection(100))
                }

                it("has nil titles by default") {
                    XCTAssertNil(collection.titleForSection(0))
                    XCTAssertNil(collection.titleForSection(100))
                }
            }
        }

        describe("frc section changes") {
            context("when a section is inserted") {
                it("adds the section") {
                    beforeEach()
                    self.assertDifference({ collection.numberOfSections() }, 1) {
                        Panda.build(managedObjectContext, name: "D")
                        managedObjectContext.processPendingChanges()
                    }
                    XCTAssertEqual("D", collection.titleForSection(3))
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectation = self.expectation(description: "section was inserted")
                    collection.collectionUpdates.observeValues { updates in
                        for update in updates {
                            if case .sectionInserted(let s) = update {
                                if s == 3 {
                                    expectation.fulfill()
                                }
                            }
                        }
                    }

                    Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectations(timeout: 1, handler: nil)
                }
            }

            context("when a section is deleted") {
                it("removes sections") {
                    beforeEach()
                    let d = Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    self.assertDifference({ collection.numberOfSections() }, -1) {
                        managedObjectContext.delete(d)
                        managedObjectContext.processPendingChanges()
                    }
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectation = self.expectation(description: "section was deleted")
                    collection.collectionUpdates.observeValues { updates in
                        for update in updates {
                            if case .sectionDeleted(let s) = update, s == 3 {
                                expectation.fulfill()
                            }
                        }
                    }
                    let d = Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    managedObjectContext.delete(d)
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectations(timeout: 1, handler: nil)
                }
            }
        }

        describe("frc object changes") {

            context("when an object is inserted") {
                it("adds the item") {
                    beforeEach()
                    self.assertDifference({ collection.numberOfItemsInSection(0) }, 1) {
                        Panda.build(managedObjectContext, name: "Alpha")
                        managedObjectContext.processPendingChanges()
                    }
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectedIndexPath = IndexPath(row: 1, section: 0)
                    let expectation = self.expectation(description: "object was inserted")

                    collection.collectionUpdates.observeValues { updates in
                        for update in updates {
                            if case .inserted(let indexPath, let object, _) = update, indexPath == expectedIndexPath && object.name == "Alpha" {
                                    expectation.fulfill()
                            }
                        }
                    }

                    Panda.build(managedObjectContext, name: "Alpha")
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectations(timeout: 1, handler: nil)
                }
            }

            context("when an object is updated") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let updatedIndexPath = IndexPath(row: 0, section: 0)
                    let expectation = self.expectation(description: "object was updated")
                    var updates: [CollectionUpdate<Panda>] = []
                    collection.collectionUpdates.observeValues {
                        updates = $0
                        expectation.fulfill()
                    }

                    one.name = "Another 'A' name"

                    self.waitForExpectations(timeout: 1, handler: nil)

                    let moved = CollectionUpdate<Panda>.moved(updatedIndexPath, updatedIndexPath, four, animated: false)
                    XCTAssertEqual(updates, [moved])
                }
            }

            context("when an object is moved") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let originalIndexPath = IndexPath(row: 1, section: 2)
                    let updatedIndexPath = IndexPath(row: 1, section: 0)
                    let expectation = self.expectation(description: "object was moved")
                    var updates: [CollectionUpdate<Panda>] = []
                    collection.collectionUpdates.observeValues {
                        updates = $0
                        expectation.fulfill()
                    }

                    four.name = "Aapple"

                    self.waitForExpectations(timeout: 1, handler: nil)

                    let moved = CollectionUpdate<Panda>.moved(originalIndexPath, updatedIndexPath, four, animated: false)
                    XCTAssertEqual(updates, [moved])
                }
            }

            context("when an object is deleted") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let deletedIndexPath = IndexPath(row: 0, section: 0)
                    let expectation = self.expectation(description: "object was deleted")
                    collection.collectionUpdates.observeValues { updates in
                        for update in updates {
                            if case .deleted(let i, let m, _) = update, i == deletedIndexPath && m.name == one.name {
                                expectation.fulfill()
                            }
                        }
                    }

                    managedObjectContext.delete(managedObjectContext.object(with: one.objectID))

                    self.waitForExpectations(timeout: 1, handler: nil)
                }
            }

        }

        describe("as a SequenceType") {
            // TODO
        }
    }
}
