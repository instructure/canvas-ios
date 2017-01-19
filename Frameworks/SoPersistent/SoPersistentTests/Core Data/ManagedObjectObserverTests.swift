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
import ReactiveSwift

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
        guard let observer = observer, let managedObjectContext = managedObjectContext else { return }
        let expectation = self.expectation(description: "object was inserted")
        observer.signal.assumeNoErrors().observeValues { change, _ in
            if case .insert = change {
                expectation.fulfill()
            }
        }
        Panda.build(managedObjectContext)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testUpdate() {
        guard let observer = observer, let object = object else { return }
        let expectation = self.expectation(description: "object was updated")
        observer.observe(object, change: .update, withExpectation: expectation)
        object.name = "test update"
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDelete() {
        guard let observer = observer, let object = object else { return }
        let expectation = self.expectation(description: "object was deleted")
        observer.observe(object, change: .delete, withExpectation: expectation)
        managedObjectContext?.delete(object)
        waitForExpectations(timeout: 1, handler: nil)
    }
}
