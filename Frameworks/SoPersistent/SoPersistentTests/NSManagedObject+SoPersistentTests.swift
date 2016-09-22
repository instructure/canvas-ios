//
//  ModelTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 2/3/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoPersistent
import SoAutomated
import CoreData
import TooLegit

class NSManagedObjectTests: XCTestCase {
    func testEntityNameMatchesOnClassName() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let entityName = Panda.entityName(context)
            XCTAssertEqual("Panda", entityName)
        }
    }

    func testFetch() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let predicate = NSPredicate(value: true)
            let request = Panda.fetch(predicate, sortDescriptors: ["name".ascending], inContext: context)

            XCTAssertEqual("Panda", request.entityName, "it sets entityName")
            XCTAssertEqual(predicate, request.predicate, "it sets predicate")
            XCTAssertEqual(["name".ascending], request.sortDescriptors ?? [], "it sets sortDescriptors")
        }
    }

    func testFetchedResults() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let frc = Panda.fetchedResults(nil, sortDescriptors: [], sectionNameKeypath: nil, inContext: context)

            XCTAssertFalse(frc.fetchRequest.returnsObjectsAsFaults, "it sets returnsObjectsAsFaults to false")
            XCTAssertEqual(30, frc.fetchRequest.fetchBatchSize, "it sets the fetchBatchSize to 30")
            XCTAssertNil(frc.cacheName, "it sets a nil cacheName")
        }
    }

    func testDelete() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let panda = Panda.build(context)
            panda.delete(inContext: context)
            XCTAssert(panda.deleted)
        }
    }

}

class ModelTests: XCTestCase {
    let session = Session.inMemory

    func testFindAll() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (alpha, beta, charlie) = seedData(context)

            let results: [Panda] = try context.findAll()
            XCTAssert(results.contains(alpha))
            XCTAssert(results.contains(beta))
            XCTAssert(results.contains(charlie))
        }
    }

    func testFindAllWithRequest() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (alpha, _, _) = seedData(context)
            let predicate = NSPredicate(format: "%K == %@", "name", "alpha")
            let request = Panda.fetch(predicate, sortDescriptors: nil, inContext: context)
            let withRequest: [Panda] = try context.findAll(fromFetchRequest: request)
            XCTAssertEqual(1, withRequest.count)
            XCTAssert(withRequest.contains(alpha))
        }

    }

    func testFindAllWithValueForKey() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (_, beta, _) = seedData(context)
            let withValue: [Panda] = try context.findAll(withValue: "beta", forKey: "name")
            XCTAssertEqual(1, withValue.count)
            XCTAssert(withValue.contains(beta))
        }
    }

    func testFindAllWithValuesForKey() throws {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (alpha, _, charlie) = seedData(context)
            let withValues: [Panda] = try context.findAll(withValues: ["alpha", "charlie"], forKey: "name")
            XCTAssertEqual(2, withValues.count)
            XCTAssert(withValues.contains(alpha))
            XCTAssert(withValues.contains(charlie))
        }
    }

    func testFindOneWithValueForKey() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (alpha, _, _) = seedData(context)
            let result: Panda? = try context.findOne(withValue: "alpha", forKey: "name")
            XCTAssertEqual(alpha, result)
        }
    }

    func testFindOneWithPredicate() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (_, beta, _) = seedData(context)
            let predicate = NSPredicate(format: "%K == %@", "name", "beta")
            let result: Panda? = try context.findOne(withPredicate: predicate)
            XCTAssertEqual(beta, result)
        }
    }

    func testFindOneWithObjectID() {
        attempt {
            let context = try session.soPersistentTestsManagedObjectContext()
            let (alpha, _, _) = seedData(context)
            let result: Panda = try context.findOne(alpha.objectID)
            XCTAssertEqual(alpha, result)
        }
    }

    func testCreate() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let created = Panda(inContext: context)
            XCTAssert(created.inserted)
        }
    }

    private func seedData(context: NSManagedObjectContext) -> (Panda, Panda, Panda) {
        let alpha = Panda.build(context, name: "alpha")
        let beta = Panda.build(context, name: "beta")
        let charlie = Panda.build(context, name: "charlie")
        return (alpha, beta, charlie)
    }
}
