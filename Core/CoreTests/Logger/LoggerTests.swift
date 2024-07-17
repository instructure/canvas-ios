//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
        Clock.reset()
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
        Clock.reset()
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
