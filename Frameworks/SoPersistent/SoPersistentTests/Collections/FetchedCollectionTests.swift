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

        describe("init") {
            context("when frc is invalid") {
                it("throws an error") {
                    let model = NSManagedObjectModel(named: "DataModel", inBundle: NSBundle(forClass: Panda.self))!
                    let context = NSManagedObjectContext.errorProneContext(model)
                    let frc = Panda.fetchedResults(nil, sortDescriptors: [], sectionNameKeypath: nil, inContext: context)
                    var theError: ErrorType?

                    do {
                        let _ = try FetchedCollection<Panda>(frc: frc)
                    } catch {
                        theError = error
                    }

                    XCTAssertNotNil(theError)
                }
            }
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
                    XCTAssertEqual(one, collection[NSIndexPath(forRow: 0, inSection: 0)])
                    XCTAssertEqual(two, collection[NSIndexPath(forRow: 0, inSection: 1)])
                    XCTAssertEqual(three, collection[NSIndexPath(forRow: 0, inSection: 2)])
                    XCTAssertEqual(four, collection[NSIndexPath(forRow: 1, inSection: 2)])
                }
            }

            context("when sections are nil") {
                class FRC: NSFetchedResultsController {
                    private override func performFetch() throws {
                        return // nil sections!
                    }
                }
                let frc = FRC(
                    fetchRequest: Panda.fetch(nil, sortDescriptors: ["name".ascending], inContext: managedObjectContext),
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
                    let expectation = self.expectationWithDescription("section was inserted")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .SectionInserted(let s) = update {
                                if s == 3 {
                                    expectation.fulfill()
                                }
                            }
                        }
                    }

                    Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when a section is deleted") {
                it("removes sections") {
                    beforeEach()
                    let d = Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    self.assertDifference({ collection.numberOfSections() }, -1) {
                        managedObjectContext.deleteObject(d)
                        managedObjectContext.processPendingChanges()
                    }
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectation = self.expectationWithDescription("section was deleted")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .SectionDeleted(let s) = update where s == 3 {
                                expectation.fulfill()
                            }
                        }
                    }
                    let d = Panda.build(managedObjectContext, name: "D")
                    managedObjectContext.processPendingChanges()

                    managedObjectContext.deleteObject(d)
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
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
                    let expectedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let expectation = self.expectationWithDescription("object was inserted")

                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Inserted(let indexPath, let object) = update
                                where indexPath == expectedIndexPath && object.name == "Alpha" {
                                    expectation.fulfill()
                            }
                        }
                    }

                    Panda.build(managedObjectContext, name: "Alpha")
                    managedObjectContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when an object is updated") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let updatedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    let expectation = self.expectationWithDescription("object was updated")
                    var updates: [CollectionUpdate<Panda>] = []
                    collection.collectionUpdates.observeNext {
                        updates = $0
                        expectation.fulfill()
                    }

                    one.name = "Another 'A' name"

                    self.waitForExpectationsWithTimeout(1, handler: nil)

                    // RADAR (rdar://279557917): Sends an `update` with two index paths so we treat it as a move.
                    let updated = CollectionUpdate<Panda>.Updated(updatedIndexPath, four)
                    XCTAssertEqual(updates, [updated])
                }
            }

            context("when an object is moved") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let originalIndexPath = NSIndexPath(forRow: 1, inSection: 2)
                    let updatedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let expectation = self.expectationWithDescription("object was moved")
                    var updates: [CollectionUpdate<Panda>] = []
                    collection.collectionUpdates.observeNext {
                        updates = $0
                        expectation.fulfill()
                    }

                    four.name = "Aapple"

                    self.waitForExpectationsWithTimeout(1, handler: nil)

                    // RADAR (rdar://279557917): Sends an `update` with two index paths so we treat it as a move.
                    let moved = CollectionUpdate<Panda>.Moved(originalIndexPath, updatedIndexPath, four)
                    XCTAssertEqual(updates, [moved])
                }
            }

            context("when an object is deleted") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let deletedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    let expectation = self.expectationWithDescription("object was deleted")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Deleted(let i, let m) = update where i == deletedIndexPath && m.name == one.name {
                                expectation.fulfill()
                            }
                        }
                    }

                    managedObjectContext.deleteObject(managedObjectContext.objectWithID(one.objectID))

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

        }

        describe("as a SequenceType") {
            // TODO
        }
    }
}
