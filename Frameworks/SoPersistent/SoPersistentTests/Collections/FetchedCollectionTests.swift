
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
    let session = Session.inMemory
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
    }

    func testDescribeFetchedCollection() {
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

        let one = Panda.build(managedObjectContext, name: "A")
        let two = Panda.build(managedObjectContext, name: "B")
        let three = Panda.build(managedObjectContext, name: "C")
        let four = Panda.build(managedObjectContext, name: "Charlie")

        describe("frc sections") {
            context("when there are sections") {
                let collection = try! Panda.collectionByFirstLetterOfName(self.session, inContext: self.managedObjectContext)

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
                    fetchRequest: Panda.fetch(nil, sortDescriptors: ["name".ascending], inContext: self.managedObjectContext),
                    managedObjectContext: self.managedObjectContext,
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

        var childContext: NSManagedObjectContext!
        var collection: FetchedCollection<Panda>!

        let beforeEach: ()->Void = {
            childContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            childContext.parentContext = self.managedObjectContext
            collection = try! Panda.collectionByFirstLetterOfName(self.session, inContext: childContext)
        }

        describe("frc section changes") {
            context("when a section is inserted") {
                it("adds the section") {
                    beforeEach()
                    self.assertDifference({ collection.numberOfSections() }, 1) {
                        Panda.build(childContext, name: "D")
                        childContext.processPendingChanges()
                    }
                    XCTAssertEqual("D", collection.titleForSection(3))
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectation = self.expectationWithDescription("section was inserted")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .SectionInserted(let s) = update where s == 3 {
                                expectation.fulfill()
                            }
                        }
                    }

                    Panda.build(childContext, name: "D")
                    childContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when a section is deleted") {
                it("removes sections") {
                    beforeEach()
                    let d = Panda.build(childContext, name: "D")
                    childContext.processPendingChanges()

                    self.assertDifference({ collection.numberOfSections() }, -1) {
                        childContext.deleteObject(d)
                        childContext.processPendingChanges()
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
                    let d = Panda.build(childContext, name: "D")
                    childContext.processPendingChanges()

                    childContext.deleteObject(d)
                    childContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }
        }

        describe("frc object changes") {

            context("when an object is inserted") {
                it("adds the item") {
                    beforeEach()
                    self.assertDifference({ collection.numberOfItemsInSection(0) }, 1) {
                        Panda.build(childContext, name: "Alpha")
                        childContext.processPendingChanges()
                    }
                }

                it("notifies collectionUpdated") {
                    beforeEach()
                    let expectedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let expectation = self.expectationWithDescription("object was inserted")
                    let newObject = Panda.build(childContext, name: "Alpha")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Inserted(let indexPath, let m) = update
                                where indexPath == expectedIndexPath && m == newObject {
                                    expectation.fulfill()
                            }
                        }
                    }

                    childContext.processPendingChanges()

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when an object is updated") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let updatedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    let expectation = self.expectationWithDescription("object was updated")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Updated(let ip, let m) = update
                                where ip == updatedIndexPath &&  m.name == "Another 'A' name" {
                                    expectation.fulfill()
                            }
                        }
                    }

                    one.name = "Another 'A' name"
                    childContext.refreshObject(childContext.objectWithID(one.objectID), mergeChanges: false)

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when an object is moved") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let originalIndexPath = NSIndexPath(forRow: 1, inSection: 2)
                    let updatedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
                    let expectation = self.expectationWithDescription("object was moved")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Moved(let i, let ii, let m) = update
                                where i == originalIndexPath && ii == updatedIndexPath && m.name == "Aapple" {
                                    expectation.fulfill()
                            }
                        }
                    }

                    four.name = "Aapple"
                    childContext.refreshObject(childContext.objectWithID(four.objectID), mergeChanges: false)

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

            context("when an object is deleted") {
                it("notifies collectionUpdated") {
                    beforeEach()
                    let deletedIndexPath = NSIndexPath(forRow: 1, inSection: 0)
                    let expectation = self.expectationWithDescription("object was deleted")
                    collection.collectionUpdates.observeNext { updates in
                        for update in updates {
                            if case .Deleted(let i, let m) = update where i == deletedIndexPath && m.name == one.name {
                                expectation.fulfill()
                            }
                        }
                    }

                    childContext.deleteObject(childContext.objectWithID(one.objectID))

                    self.waitForExpectationsWithTimeout(1, handler: nil)
                }
            }

        }

        describe("as a SequenceType") {
            // TODO
        }
    }

}
