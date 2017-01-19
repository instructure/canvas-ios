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
import SoPersistent
import SoAutomated
import CoreData
import TooLegit

import Photos
import CoreLocation

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
            let request: NSFetchRequest<Panda> = context.fetch(predicate, sortDescriptors: ["name".ascending])

            XCTAssertEqual("Panda", request.entityName, "it sets entityName")
            XCTAssertEqual(predicate, request.predicate, "it sets predicate")
            XCTAssertEqual(["name".ascending], request.sortDescriptors ?? [], "it sets sortDescriptors")
        }
    }

    func testFetchedResults() {
        attempt {
            let session = Session.inMemory
            let context = try session.soPersistentTestsManagedObjectContext()
            let frc: NSFetchedResultsController<Panda> = context.fetchedResults(nil, sortDescriptors: [], sectionNameKeypath: nil)

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
            XCTAssert(panda.isDeleted)
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
            let request: NSFetchRequest<Panda> = context.fetch(predicate, sortDescriptors: [])
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
            XCTAssert(created.isInserted)
        }
    }

    fileprivate func seedData(_ context: NSManagedObjectContext) -> (Panda, Panda, Panda) {
        let alpha = Panda.build(context, name: "alpha")
        let beta = Panda.build(context, name: "beta")
        let charlie = Panda.build(context, name: "charlie")
        return (alpha, beta, charlie)
    }
}
