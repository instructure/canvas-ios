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
    
    

import Foundation
import SoAutomated
import CoreData
import SoPersistent
import XCTest
import TooLegit

class NSManagedObjectContextTests: XCTestCase {
    let session = Session.inMemory
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
    }

    func testDescribeInit() {
        describe("init(storeURL:model:concurrencyType:") {

            let model = NSManagedObjectModel(named: "DataModel", inBundle: Bundle(for: Panda.self))!

            context("when given valid parameters") {
                let storeURL = self.session.localStoreDirectoryURL.appendingPathComponent("test.sqlite")
                let context = try! NSManagedObjectContext(storeURL: storeURL, model: model, concurrencyType: .mainQueueConcurrencyType, cacheReset: {})

                it("is initialized with a persistent store coordinator") {
                    XCTAssertNotNil(context)
                    XCTAssertNotNil(context.persistentStoreCoordinator)
                }

                it("defaults the concurrencyType") {
                    let context = try! NSManagedObjectContext(storeURL: storeURL, model: model, cacheReset: {})
                    XCTAssertEqual(NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType, context.concurrencyType)
                }
            }
        }
    }

    func testDescribeSaveOrRollback() {
        context("when it saves") {
            it("returns true") {
                XCTAssert(self.managedObjectContext.saveOrRollback())
            }
        }
    }

    func testDescribePerformChanges() {
        it("performs the changes") {
            let expectation = self.expectation(description: "block was performed")
            self.managedObjectContext.performChanges {
                expectation.fulfill()
            }
            self.waitForExpectations(timeout: 1, handler: nil)
        }
    }

}
