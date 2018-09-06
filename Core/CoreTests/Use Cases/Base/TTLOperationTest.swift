//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

        let ttlOperation = TTLOperation(key: "ttl", database: db, operation: block)
        addOperationAndWait(ttlOperation)

        XCTAssert(didRun)
    }

    func testItDoesNotRunOperationIfTTLNotExpired() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: db, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: db, operation: block2)
        addOperationAndWait(secondRun)

        XCTAssertEqual(runCount, 1)
    }

    func testItDoesRunOperationIfTTLExpired() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: db, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: db, operation: block2)
        let oneDayFromNow = Clock.currentTime() + 60 * 60 * 24
        Clock.timeTravel(to: oneDayFromNow) {
            addOperationAndWait(secondRun)
        }

        XCTAssertEqual(runCount, 2)
    }

    func testItDoesRunOperationIfForced() {
        var runCount = 0

        // Run it once to set TTL
        let block1 = BlockOperation {
            runCount += 1
        }
        let firstRun = TTLOperation(key: "ttl", database: db, operation: block1)
        addOperationAndWait(firstRun)

        // Second run
        let block2 = BlockOperation {
            runCount += 1
        }
        let secondRun = TTLOperation(key: "ttl", database: db, operation: block2, force: true)
        addOperationAndWait(secondRun)

        XCTAssertEqual(runCount, 2)
    }
}
