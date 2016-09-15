//
//  SyncOperationTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import SoAutomated
import CoreData
import TooLegit
import SoPersistent
import ReactiveCocoa

class SyncSignalProducerTests: XCTestCase {
    let session = Session.starWarsAPI
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
    }

    func test_itCreatesObjects() {
        stub(session, "people") { expectation in
            let request = try! self.session.GET("/people")
            let remote = self.session.paginatedJSONSignalProducer(request, keypath: "results")

            SWPerson.syncSignalProducer(inContext: self.managedObjectContext, fetchRemote: remote)
                .on(failed: { e in XCTFail("error: \(e)") })
                .startWithCompleted { expectation.fulfill() }
        }

        XCTAssertEqual(10, SWPerson.count(inContext: managedObjectContext))
    }

    func test_itUpdatesObjects() {
        var disposable: Disposable?
        let luke = SWPerson.build(managedObjectContext, name: "Luke Skywalker", height: "100")
        try! managedObjectContext.save()

        let local = NSPredicate(format: "%K == %@", "name", "Luke Skywalker")

        stub(session, "luke") { expectation in
            let request = try! self.session.GET("/people/1")
            let remote = self.session.JSONSignalProducer(request).map { [$0 ] }
            disposable = SWPerson.syncSignalProducer(local, inContext: self.managedObjectContext, fetchRemote: remote)
                .startWithCompleted { expectation.fulfill() }
        }

        XCTAssertEqual("172", luke.height)
        disposable?.dispose()
    }

    func test_itDeletesObjects() {
        let aragorn = SWPerson.build(managedObjectContext, name: "Aragorn")
        try! managedObjectContext.save()

        stub(session, "people") { expectation in
            let request = try! self.session.GET("/people")
            let remote = self.session.paginatedJSONSignalProducer(request, keypath: "results")

            SWPerson.syncSignalProducer(inContext: self.managedObjectContext, fetchRemote: remote)
                .startWithCompleted { expectation.fulfill() }
        }

        XCTAssert(aragorn.deleted)
    }

    func test_itPropagatesSaveErrors() {
        let model = NSManagedObjectModel(named: "DataModel", inBundle: NSBundle(forClass: SWPerson.self))!
        let context = NSManagedObjectContext.errorProneContext(model)
        var error: NSError?

        stub(session, "people") { expectation in
            let request = try! self.session.GET("/people")
            let remote = self.session.paginatedJSONSignalProducer(request, keypath: "results")

            SWPerson.syncSignalProducer(inContext: context, fetchRemote: remote)
                .startWithFailed { e in expectation.fulfill(); error = e }
        }

        XCTAssertNotNil(error)
    }
}
