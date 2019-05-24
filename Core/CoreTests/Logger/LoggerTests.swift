//
// Copyright (C) 2018-present Instructure, Inc.
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

import CoreData
import Foundation
import XCTest
@testable import Core

class LoggerTests: CoreTestCase {
    var theLogger: Logger!

    func waitForCount(_ count: Int) {
        let done = expectation(for: NSPredicate(block: { (client, _) -> Bool in
            let events: [LogEvent] = (client as! NSManagedObjectContext).fetch()
            return events.count == count
        }), evaluatedWith: databaseClient)
        wait(for: [done], timeout: 5)
    }

    override func setUp() {
        super.setUp()

        theLogger = Logger()
        theLogger.database = database
    }
    func testLog() {
        let now = Date()
        Clock.mockNow(now)
        theLogger.log("log message")
        waitForCount(1)
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "log message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .log)
    }

    func testError() {
        let now = Date()
        Clock.mockNow(now)
        theLogger.error("error message")
        waitForCount(1)
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "error message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .error)
    }

    func testClearAll() {
        LogEvent.make()
        LogEvent.make()
        waitForCount(2)

        theLogger.clearAll()
        waitForCount(0)
        databaseClient.refresh()
        let after: [LogEvent] = databaseClient.fetch()
        XCTAssertEqual(after.count, 0)
    }
}
