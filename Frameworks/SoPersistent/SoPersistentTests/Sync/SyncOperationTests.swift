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
import Nimble

let currentBundle = NSBundle(forClass: SyncSignalProducerTests.self)

class SyncSignalProducerTests: XCTestCase {
    let session = Session.starWarsAPI
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
    }

    func test_itCreatesObjects() {
        session.playback("people", in: currentBundle) {
            waitUntil { done in
                let request = try! self.session.GET("/people")
                let remote = self.session.paginatedJSONSignalProducer(request, keypath: "results")
                SWPerson.syncSignalProducer(inContext: self.managedObjectContext, fetchRemote: remote).startWithCompletedAction(done)
            }
        }

        XCTAssertEqual(10, SWPerson.count(inContext: managedObjectContext))
    }

    func test_itUpdatesObjects() {
        var disposable: Disposable?
        let luke = SWPerson.build(managedObjectContext, name: "Luke Skywalker", height: "100")
        try! managedObjectContext.save()

        let local = NSPredicate(format: "%K == %@", "name", "Luke Skywalker")

        session.playback("luke", in: currentBundle) {
            let request = try! self.session.GET("/people/1")
            let remote = self.session.JSONSignalProducer(request).map { [$0 ] }
            waitUntil { done in
                disposable = SWPerson.syncSignalProducer(local, inContext: self.managedObjectContext, fetchRemote: remote).startWithCompletedAction(done)
            }
        }

        XCTAssertEqual("172", luke.height)
        disposable?.dispose()
    }

    func test_itDeletesObjects() {
        let aragorn = SWPerson.build(managedObjectContext, name: "Aragorn")
        try! managedObjectContext.save()

        session.playback("people", in: currentBundle) {
            waitUntil { done in
                let request = try! self.session.GET("/people")
                let remote = self.session.paginatedJSONSignalProducer(request, keypath: "results")

                SWPerson.syncSignalProducer(inContext: self.managedObjectContext, fetchRemote: remote).startWithCompletedAction(done)
            }
        }

        XCTAssert(aragorn.deleted)
    }
}
