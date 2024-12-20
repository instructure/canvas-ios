//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Combine
@testable import Core
import XCTest

class CDAllCoursesCourseItemSearchTests: CoreTestCase {
    var testee: CurrentValueSubject<[CDAllCoursesCourseItem], Error>!
    var query: PassthroughSubject<String, Error>!

    override func setUp() {
        super.setUp()

        let item1: CDAllCoursesCourseItem = databaseClient.insert()
        item1.name = "abC"
        item1.courseCode = "item1"
        let item2: CDAllCoursesCourseItem = databaseClient.insert()
        item2.name = "def"
        item2.courseCode = "item2"

        testee = CurrentValueSubject<[CDAllCoursesCourseItem], Error>([item1, item2])
        query = PassthroughSubject<String, Error>()
    }

    public func testCaseInsensitiveSearch() {
        search("c", expectedResult: ["abC"])
        search("A", expectedResult: ["abC"])
    }

    public func testEmptySearch() {
        search("", expectedResult: ["abC", "def"])
    }

    public func testNonExistingSearch() {
        search("x", expectedResult: [])
    }

    public func testInvalidSearch() {
        search("bCd", expectedResult: [])
    }

    public func testCourseCodeSearch() {
        search("1", expectedResult: ["abC"])
    }

    private func search(_ queryString: String, expectedResult: [String]) {
        let valueReceived = expectation(description: "Value received")
        let subscription = testee
            .filter(with: query)
            .map {
                $0.map { item in
                    item.name
                }
            }
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { itemNames in
                    valueReceived.fulfill()
                    XCTAssertEqual(itemNames, expectedResult)
                }
            )
        query.send(queryString)
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }
}
