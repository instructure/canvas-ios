//
//  SessionTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
