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
