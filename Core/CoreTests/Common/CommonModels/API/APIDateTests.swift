//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
@testable import Core
import XCTest

class APIDateTests: CoreTestCase {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    func testInit() {
        XCTAssertNil(APIDate(rawValue: nil))
        let date: Date? = Clock.now
        XCTAssertEqual(APIDate(rawValue: date)?.rawValue, date)
        let date2 = Clock.now
        XCTAssertEqual(APIDate(rawValue: date2).rawValue, date2)
    }

    func testCodableValid() throws {
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601
        let date = DateComponents(calendar: .current, year: 2020, month: 3, day: 14).date!
        let apiDate = APIDate(rawValue: date)
        XCTAssertEqual(
            try decoder.decode(APIDate.self, from: try encoder.encode(date)),
            apiDate
        )
        XCTAssertEqual(
            try decoder.decode(APIDate.self, from: try encoder.encode(date.timeIntervalSince1970 * 1000)),
            apiDate
        )
        XCTAssertEqual(try encoder.encode(apiDate), try encoder.encode(date))
        encoder.dateEncodingStrategy = .millisecondsSince1970
        XCTAssertEqual(
            try decoder.decode(APIDate.self, from: try encoder.encode(date)),
            apiDate
        )
        XCTAssertEqual(try encoder.encode(apiDate), try encoder.encode(date))
        decoder.dateDecodingStrategy = .millisecondsSince1970
        XCTAssertEqual(
            try decoder.decode(APIDate.self, from: try encoder.encode(date)),
            apiDate
        )

        XCTAssertThrowsError(try decoder.decode(APIDate.self, from: try encoder.encode("")))
        XCTAssertThrowsError(try decoder.decode(APIDate.self, from: try encoder.encode(true)))
    }
}
