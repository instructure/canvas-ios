//
//  FetchedCollectionTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 2/3/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoPersistent
import CoreData

class FetchedCollectionTests: SoPersistentTests {

    var pandas: [Panda] = []

    class Model {}
    class ViewModel {}

    override func setUp() {
        super.setUp()
        pandas = pandaData()
    }

    func pandaData() -> [Panda] {
        let one = Panda.insertNewObjectInContext(managedObjectContext)
        one.name = "Bai Yun"
        one.birthday = NSDate.new(7, 11, 1991)

        let two = Panda.insertNewObjectInContext(managedObjectContext)
        two.name = "Bao Bao"
        two.birthday = NSDate.new(23, 8, 2013)

        let three = Panda.insertNewObjectInContext(managedObjectContext)
        three.name = "Chu-Lin"
        three.birthday = NSDate.new(29, 4, 1996)

        let four = Panda.insertNewObjectInContext(managedObjectContext)
        four.name = "Hua Mei"
        four.birthday = NSDate.new(21, 8, 1999)

        return [one, two, three, four]
    }

    func testThatItCanBeInitialized() {
        // Given
        let request = NSFetchRequest(entityName: "Panda")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        let viewModelFactory: Model->ViewModel = { _ in ViewModel() }

        // When
        let collection = try! FetchedCollection<Model, ViewModel>(
            frc: frc, viewModelFactory: viewModelFactory)

        // Then
        XCTAssertNotNil(collection)
    }

    func testThatItCanHaveOneSection() {
        // Given
        let request = NSFetchRequest(entityName: "Panda")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        let viewModelFactory: Model->ViewModel = { _ in ViewModel() }

        // When
        let collection = try! FetchedCollection<Model, ViewModel>(
            frc: frc, viewModelFactory: viewModelFactory)

        // Then
        XCTAssertEqual(1, collection.numberOfSections)
        XCTAssertEqual(4, collection.numberOfItemsInSection(0))
    }

    func testThatItCanHaveManySections() {
        // Given
        let request = NSFetchRequest(entityName: "Panda")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "firstLetterOfName",
            cacheName: nil)
        let viewModelFactory: Model->ViewModel = { _ in ViewModel() }

        // When
        let collection = try! FetchedCollection<Model, ViewModel>(
            frc: frc, viewModelFactory: viewModelFactory)

        // Then
        XCTAssertEqual(3, collection.numberOfSections)
        XCTAssertEqual(2, collection.numberOfItemsInSection(0))
        XCTAssertEqual(1, collection.numberOfItemsInSection(1))
        XCTAssertEqual(1, collection.numberOfItemsInSection(2))
        XCTAssertEqual("B", collection.titleForSection(0))
        XCTAssertEqual("C", collection.titleForSection(1))
        XCTAssertEqual("H", collection.titleForSection(2))
    }

    func testWhenSectionsAreNil() {
        // Given
        class MyFRC: NSFetchedResultsController {
            private override func performFetch() throws {
                // no-op
            }
        }
        let request = NSFetchRequest(entityName: "Panda")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = MyFRC(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        let viewModelFactory: Model->ViewModel = { _ in ViewModel() }

        // When
        let collection = try! FetchedCollection<Model, ViewModel>(
            frc: frc, viewModelFactory: viewModelFactory)

        // Then
        XCTAssertEqual(0, collection.numberOfSections)
        XCTAssertEqual(0, collection.numberOfItemsInSection(0))
        XCTAssertEqual("", collection.titleForSection(0))
    }


}

// MARK: - ExistingFetchedCollectionTests

// This class has a pre-built FetchedCollection as a property to minimize setup
class ExistingFetchedCollectionTests: FetchedCollectionTests {

    var fetchedCollection: FetchedCollection<Panda, PandaViewModel>!

    override func setUp() {
        super.setUp()
        setUpCollection()
    }

    func setUpCollection() {
        /**
         The `fetchedCollection` is sectioned by the first letter of panda name and ordered ascending
         within each section by the name
        */
        let request = NSFetchRequest(entityName: "Panda")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: "firstLetterOfName",
            cacheName: nil)
        let viewModelFactory: Panda->PandaViewModel = { panda in PandaViewModel(panda: panda) }

        fetchedCollection = try! FetchedCollection<Panda, PandaViewModel>(
            frc: frc, viewModelFactory: viewModelFactory)
    }

    func testSubscript() {
        let one = fetchedCollection[NSIndexPath(forRow: 0, inSection: 0)].panda
        let two = fetchedCollection[NSIndexPath(forRow: 1, inSection: 0)].panda
        let three = fetchedCollection[NSIndexPath(forRow: 0, inSection: 1)].panda
        let four = fetchedCollection[NSIndexPath(forRow: 0, inSection: 2)].panda

        XCTAssertEqual(["Bai Yun", "Bao Bao", "Chu-Lin", "Hua Mei"], [one.name, two.name, three.name, four.name])
    }

    func testNumberOfItemsInSection() {
        XCTAssertEqual(2, fetchedCollection.numberOfItemsInSection(0))
        XCTAssertEqual(1, fetchedCollection.numberOfItemsInSection(1))
        XCTAssertEqual(1, fetchedCollection.numberOfItemsInSection(2))
    }

    func testObjectAtIndexPath() {
        let one = fetchedCollection.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        let two = fetchedCollection.objectAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        let three = fetchedCollection.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        let four = fetchedCollection.objectAtIndexPath(NSIndexPath(forRow: 0, inSection: 2))

        XCTAssertEqual(["Bai Yun", "Bao Bao", "Chu-Lin", "Hua Mei"], [one.name, two.name, three.name, four.name])
    }

    /**
     Helper method for fulfilling an expectation that a specific CollectionUpdate is
     passed to the `collectionUpdated` block
    */
    func expectUpdate(expectation: XCTestExpectation, update: CollectionUpdate) -> ([CollectionUpdate] -> Void) {
        return { updateBatch in
            updateBatch.forEach {
                if $0 == update {
                    expectation.fulfill()
                }
            }
        }
    }

    func testInsertingASection() {
        // Given
        guard fetchedCollection.numberOfSections == 3 else { fatalError("expected 3 sections") }
        let expectation = expectationWithDescription("collectionUpdated was called")
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .SectionInserted(3))

        // When
        let newSectionPanda = Panda.insertNewObjectInContext(managedObjectContext)
        newSectionPanda.name = "Po" // P should be a new section
        newSectionPanda.birthday = NSDate.new(2, 2, 2016)

        // Then
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual(4, fetchedCollection.numberOfSections, "should end up with 4 sections")
    }


    func testDeletingASection() {
        // Given
        guard fetchedCollection.numberOfSections == 3 else { fatalError("expected 3 sections") }
        let expectation = expectationWithDescription("section 2 was deleted")
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .SectionDeleted(2))

        // When
        let pandaToDelete = pandas[3] // Hua Mei is the only H panda
        managedObjectContext.deleteObject(pandaToDelete)

        // Then
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual(2, fetchedCollection.numberOfSections, "should end up with 2 sections")
    }

    func testInsertingAnObject() {
        // Given
        let expectedIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        guard fetchedCollection.numberOfItemsInSection(expectedIndexPath.section) == 1 else {
            fatalError("unexpected number of items in section")
        }
        let expectation = expectationWithDescription("item was added to section")
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .Inserted(expectedIndexPath))

        // When
        let newPanda = Panda.insertNewObjectInContext(managedObjectContext)
        newPanda.name = "Chuang Chuang"
        newPanda.birthday = NSDate.new(6, 8, 2000)

        // Then
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual(2, fetchedCollection.numberOfItemsInSection(1))
    }

    func testUpdatingAnObject() {
        // Given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let panda = fetchedCollection.objectAtIndexPath(indexPath)
        guard panda.name == "Bai Yun" else { fatalError("unexpected panda") }
        let expectation = expectationWithDescription("item was updated")

        /*
         We would expect an .Update here but instead we get a .Move where `indexPath` and
         `newIndexPath` are the same which is definitely a bug. See: rdar://22380191
         We will test for a .Move now so the test will fail once Apple fixes the bug.
         */
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .Moved(indexPath, indexPath))

        // When
        try! managedObjectContext.save()
        panda.name = "Bai Yum"

        // Then
        XCTAssert(panda.updated)
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual("Bai Yum", fetchedCollection.objectAtIndexPath(indexPath).name)

    }

    func testMovingAnObject() {
        // Given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let newIndexPath = NSIndexPath(forRow: 1, inSection: 1)
        let panda = fetchedCollection.objectAtIndexPath(indexPath)
        guard panda.name == "Bai Yun" else { fatalError("unexpected panda") }
        let expectation = expectationWithDescription("item was moved")
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .Moved(indexPath, newIndexPath))

        // When
        try! managedObjectContext.save()
        panda.name = "Chuang Chuang"

        // Then
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual("Chuang Chuang", fetchedCollection.objectAtIndexPath(newIndexPath).name)
    }

    func testDeletingAnObject() {
        // Given
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        let panda = fetchedCollection.objectAtIndexPath(indexPath)
        guard fetchedCollection.numberOfItemsInSection(indexPath.section) == 2 else {
            fatalError("wrong number of pandas in section")
        }
        let expectation = expectationWithDescription("item was deleted")
        fetchedCollection.collectionUpdated = expectUpdate(expectation, update: .Deleted(indexPath))

        // When
        managedObjectContext.deleteObject(panda)

        // Then
        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual(1, fetchedCollection.numberOfItemsInSection(indexPath.section))
    }

}

// MARK: - Utils

func ==(a: CollectionUpdate, b: CollectionUpdate) -> Bool {
    switch (a, b) {
    case (.SectionInserted(let a), .SectionInserted(let b)) where a == b: return true
    case (.SectionDeleted(let a), .SectionDeleted(let b)) where a == b: return true
    case (.Inserted(let a), .Inserted(let b)) where a == b: return true
    case (.Updated(let a), .Updated(let b)) where a == b: return true
    case (.Moved(let a, let aa), .Moved(let b, let bb)) where a == b && aa == bb: return true
    case (.Deleted(let a), .Deleted(let b)) where a == b: return true
    default: return false
    }
}