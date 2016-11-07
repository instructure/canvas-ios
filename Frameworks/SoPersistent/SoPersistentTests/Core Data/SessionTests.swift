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
@testable import SoPersistent
import CoreData
@testable import TooLegit

class SessionTests: XCTestCase {

    func testManagedObjectContext() {
        let session = Session.inMemory
        let storeID = StoreID(
            storeName: "PandaKit",
            modelFileName: "DataModel",
            modelFileBundle: NSBundle(forClass: Panda.self),
            localizedErrorDescription: "Uh oh")

        it("finds or creates a managed object context") {
            let firstContext = try! session.managedObjectContext(storeID)
            let secondContext = try! session.managedObjectContext(storeID)
            XCTAssert(firstContext === secondContext)
        }

    }

}

class StoreIDTests: XCTestCase {

    func testDescribeInit() {
        let storeName = "PandaKit"
        let bundle = NSBundle(forClass: Panda.self)
        let errorDescription = "Uh oh"

        it("can be initialized with a model file") {
            let modelFileName = "DataModel"
            let storeID = StoreID(storeName: storeName, modelFileName: modelFileName, modelFileBundle: bundle, localizedErrorDescription: errorDescription)

            XCTAssertNotNil(storeID)
        }

        it("can be initialized with a model") {
            let model = NSManagedObjectModel(named: "DataModel", inBundle: bundle)!
            let storeID = StoreID(storeName: storeName, model: model, localizedErrorDescription: errorDescription)
            XCTAssertNotNil(storeID)
        }
    }

}
