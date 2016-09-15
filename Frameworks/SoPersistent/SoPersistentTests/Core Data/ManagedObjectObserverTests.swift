//
//  ManagedObjectObserverTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 2/9/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoPersistent
import SoAutomated
import CoreData
import TooLegit
import ReactiveCocoa

class ManagedObjectObserverChangeTests: XCTestCase {
    let session = Session.inMemory
    var observer: ManagedObjectObserver<Panda>?
    var object: Panda?
    var managedObjectContext: NSManagedObjectContext?

    override func setUp() {
        super.setUp()
        attempt {
            if let managedObjectContext = try? session.soPersistentTestsManagedObjectContext() {
                self.managedObjectContext = managedObjectContext
                object = Panda.build(managedObjectContext)
                try managedObjectContext.save()
                let predicate = NSPredicate(format: "%K == %@", "id", "1")
                observer = try ManagedObjectObserver<Panda>(predicate: predicate, inContext: managedObjectContext)
            }
        }
    }

    func testInsert() {
        guard let observer = observer, managedObjectContext = managedObjectContext else { return }
        let expectation = expectationWithDescription("object was inserted")
        let inserted = Panda.build(managedObjectContext)
        observer.observe(inserted, change: .Insert, withExpectation: expectation)
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testUpdate() {
        guard let observer = observer, object = object else { return }
        let expectation = expectationWithDescription("object was updated")
        observer.observe(object, change: .Update, withExpectation: expectation)
        object.name = "test update"
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testDelete() {
        guard let observer = observer, object = object else { return }
        let expectation = expectationWithDescription("object was deleted")
        observer.observe(object, change: .Delete, withExpectation: expectation)
        managedObjectContext?.deleteObject(object)
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}

class ManagedObjectObserverTests: XCTestCase {
    func testInitThrows() {
        attempt {
            let session = Session.inMemory
            let predicate = NSPredicate(value: true)
            guard let model = try session.soPersistentTestsManagedObjectContext().persistentStoreCoordinator?.managedObjectModel else {
                XCTFail("expected a managedObjectModel")
                return
            }
            let errorContext = NSManagedObjectContext.errorProneContext(model)
            XCTAssertThrowsError(try ManagedObjectObserver<Panda>(predicate: predicate, inContext: errorContext))
        }
    }
}
