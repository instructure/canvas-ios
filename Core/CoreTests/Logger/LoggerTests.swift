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

import Foundation
import XCTest
@testable import Core

class LoggerTests: CoreTestCase {
    var theLogger: Logger!
    var updated: XCTestExpectation?
    lazy var events: Store<LocalUseCase<LogEvent>> = environment.subscribe(scope: .all(orderBy: #keyPath(LogEvent.timestamp))) { [weak self] in
        self?.updated?.fulfill()
    }

    override func setUp() {
        super.setUp()

        theLogger = Logger()
        theLogger.database = database
        events.refresh()
    }
    func testLog() {
        let now = Date()
        Clock.mockNow(now)
        updated = expectation(description: "updated")
        updated?.assertForOverFulfill = false
        theLogger.log("log message")
        wait(for: [updated!], timeout: 1)
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "log message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .log)
    }

    func testError() {
        let now = Date()
        Clock.mockNow(now)
        updated = expectation(description: "updated")
        updated?.assertForOverFulfill = false
        theLogger.error("error message")
        wait(for: [updated!], timeout: 1)
        let event: LogEvent = databaseClient.fetch().first!
        XCTAssertEqual(event.message, "error message")
        XCTAssertEqual(event.timestamp, now)
        XCTAssertEqual(event.type, .error)
    }

    func testClearAll() {
        LogEvent.make()
        LogEvent.make()
        let before: [LogEvent] = databaseClient.fetch()
        XCTAssertEqual(before.count, 2)

        updated = expectation(description: "updated")
        updated?.assertForOverFulfill = false
        theLogger.clearAll()
        wait(for: [updated!], timeout: 1)
        databaseClient.refresh()
        let after: [LogEvent] = databaseClient.fetch()
        XCTAssertEqual(after.count, 0)
    }
}
