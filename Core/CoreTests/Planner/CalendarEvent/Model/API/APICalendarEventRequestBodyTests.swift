//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import XCTest
@testable import Core

final class APICalendarEventRequestBodyTests: XCTestCase {

    private enum TestConstants {
        static let contextCode = "some contextCode"
        static let title = "some title"
        static let description = "some description"
        static let startAt = Clock.now
        static let endAt = Clock.now.addHours(1)
        static let locationName = "some locationName"
        static let locationAddress = "some locationAddress"
        static let timeZone = "some timeZone"
    }

    func testEncoding() throws {
        let testee = APICalendarEventRequestBody.make(
            context_code: TestConstants.contextCode,
            title: TestConstants.title,
            description: TestConstants.description,
            start_at: TestConstants.startAt,
            end_at: TestConstants.endAt,
            location_name: TestConstants.locationName,
            location_address: TestConstants.locationAddress,
            time_zone_edited: TestConstants.timeZone
        )

        let json = try testee.encodeToJson()

        XCTAssertEqual(json.contains(jsonKey: "context_code", value: TestConstants.contextCode), true)
        XCTAssertEqual(json.contains(jsonKey: "title", value: TestConstants.title), true)
        XCTAssertEqual(json.contains(jsonKey: "description", value: TestConstants.description), true)
        XCTAssertEqual(json.contains(jsonKey: "start_at", value: TestConstants.startAt.isoString()), true)
        XCTAssertEqual(json.contains(jsonKey: "end_at", value: TestConstants.endAt.isoString()), true)
        XCTAssertEqual(json.contains(jsonKey: "location_name", value: TestConstants.locationName), true)
        XCTAssertEqual(json.contains(jsonKey: "location_address", value: TestConstants.locationAddress), true)
        XCTAssertEqual(json.contains(jsonKey: "time_zone_edited", value: TestConstants.timeZone), true)
    }

    func testEncodingShouldNotSkipNils() throws {
        let testee = APICalendarEventRequestBody.make(
            description: nil,
            location_name: nil,
            location_address: nil,
            time_zone_edited: nil
        )

        let json = try testee.encodeToJson()

        XCTAssertEqual(json.contains(jsonKey: "description", value: nil), true)
        XCTAssertEqual(json.contains(jsonKey: "location_name", value: nil), true)
        XCTAssertEqual(json.contains(jsonKey: "location_address", value: nil), true)
        XCTAssertEqual(json.contains(jsonKey: "time_zone_edited", value: nil), true)
    }
}
