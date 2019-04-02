//
// Copyright (C) 2017-present Instructure, Inc.
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

import XCTest
@testable import Core

class DateExtensionsTests: XCTestCase {
    func testIsoString() {
        XCTAssertEqual(Date(timeIntervalSince1970: 0).isoString(), "1970-01-01T00:00:00Z")
    }

    func testFromISOString() {
        XCTAssertEqual(Date(fromISOString: "bad wolf"), nil)
        XCTAssertEqual(Date(fromISOString: "1970-01-01T00:00:00Z"), Date(timeIntervalSince1970: 0))
    }

    func testFetchedResultsControllerComparatorSortNilsToBottom() {
        let a: NSDate = Date().addDays(2) as NSDate
        let b: NSDate = Date().addDays(3) as NSDate

        let result1 = a.fetchedResultsControllerComparatorSortNilsToBottom(b)
        let result2  = b.fetchedResultsControllerComparatorSortNilsToBottom(a)
        let result3  = a.fetchedResultsControllerComparatorSortNilsToBottom(a)

        XCTAssertEqual(result1, .orderedDescending)
        XCTAssertEqual(result2, .orderedAscending)
        XCTAssertEqual(result3, .orderedSame)
    }
}
