//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

@testable import Core
import XCTest

class APIJSONDecoderTests: XCTestCase {

    struct TestModel: Codable, Equatable {
        var date: Date?
    }

    // MARK: - Decoding Tests

    func test_decode_validISO8601Date() throws {
        let json = """
        {"date": "2025-01-15T10:30:00Z"}
        """
        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        let result = try decoder.decode(TestModel.self, from: data)

        XCTAssertNotNil(result.date)

        let calendar = newCalendar()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: result.date!)
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 10)
        XCTAssertEqual(components.minute, 30)
        XCTAssertEqual(components.second, 0)
    }

    func test_decode_ISO8601DateWithFractionalSeconds() throws {
        let json = """
        {"date": "2019-06-02T18:07:28.123Z"}
        """
        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        let result = try decoder.decode(TestModel.self, from: data)

        XCTAssertNotNil(result.date)

        let calendar = newCalendar()
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: result.date!)
        XCTAssertEqual(components.year, 2019)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 2)
        XCTAssertEqual(components.hour, 18)
        XCTAssertEqual(components.minute, 7)
        XCTAssertEqual(components.second, 28)
        XCTAssertTrue(abs(Double(components.nanosecond ?? 0) / 1_000_000_000 - 0.123) < 0.00001)
    }

    func test_decode_nullDateAsNil() throws {
        let json = """
        {"date": null}
        """
        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        let result = try decoder.decode(TestModel.self, from: data)

        XCTAssertNil(result.date)
    }

    func test_decode_malformedDateWithNegativeYear() throws {
        let json = """
        {"date": "-3033-05-31T07:51:58Z"}
        """
        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        let result = try decoder.decode(TestModel.self, from: data)

        // ISO8601DateFormatter accepts negative years, so this will decode successfully
        // The important thing is it doesn't crash like JSONDecoder's .iso8601 strategy would
        XCTAssertNotNil(result.date, "Date with negative year should decode (ISO8601DateFormatter accepts it)")

        // Note: "-3033" in ISO8601 is interpreted as 3034 BCE (era 0, year 3034) in Gregorian calendar
        // The important is that it decodes successfully.
        let calendar = newCalendar()
        let components = calendar.dateComponents([.era, .year, .month, .day], from: result.date!)
        XCTAssertEqual(components.era, 0, "Era should be 0 (BCE)")
        XCTAssertEqual(components.year, 3034, "Year 3034 BCE in Gregorian calendar")
        XCTAssertEqual(components.month, 5)
        XCTAssertEqual(components.day, 31)
    }

    func test_decode_invalidDateString_throwing_error() throws {
        let json = """
        {"date": "not-a-date"}
        """

        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        XCTAssertThrowsError(try decoder.decode(TestModel.self, from: data))
    }

    func test_decode_emptyString_throwing_error() throws {
        let json = """
        {"date": ""}
        """
        let data = json.data(using: .utf8)!
        let decoder = APIJSONDecoder()

        XCTAssertThrowsError(try decoder.decode(TestModel.self, from: data))
    }

    // MARK: Helpers

    private func newCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }
}
