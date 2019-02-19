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

class TTLOperationTest: CoreTestCase {
    func testItRunsOperationWhenFirstTime() {
        var didRun = false
        let block = BlockOperation {
            didRun = true
        }

        let ttlOperation = TTLOperation(key: "ttl", database: database, operation: block)
        addOperationAndWait(ttlOperation)

        XCTAssert(didRun)
    }

    func testItDoesNotRunOperationIfTTLNotExpired() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: database, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: database, operation: block2)
        addOperationAndWait(secondRun)

        XCTAssertEqual(runCount, 1)
    }

    func testItDoesRunOperationIfTTLExpired() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: database, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: database, operation: block2)
        Clock.mockNow(Date().addDays(1))
        addOperationAndWait(secondRun)

        XCTAssertEqual(runCount, 2)
    }

    func testItDoesRunOperationIfForced() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: database, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: database, operation: block2, force: true)
        addOperationAndWait(secondRun)

        XCTAssertEqual(runCount, 2)
    }
}
