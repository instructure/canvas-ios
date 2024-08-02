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

final class CreateCalendarEventTests: CoreTestCase {

    private enum TestConstants {
        static let contextCode = "some contextCode"
        static let title = "some title"
        static let description = "some description"
        static let startAt = Clock.now
        static let endAt = Clock.now.addHours(1)
        static let locationName = "some locationName"
        static let locationAddress = "some locationAddress"

        static let responseId: ID = "response id"
        static let responseContextCode = "response contextCode"
        static let responseTitle = "response title"
        static let responseDescription = "response description"
        static let responseStartAt = Clock.now.addYears(1)
        static let responseEndAt = Clock.now.addHours(1).addYears(1)
        static let responseLocationName = "response locationName"
        static let responseLocationAddress = "response locationAddress"
    }

    private var testee: CreateCalendarEvent!

    override func setUp() {
        super.setUp()
        testee = .init(
            context_code: TestConstants.contextCode,
            title: TestConstants.title,
            description: TestConstants.description,
            start_at: TestConstants.startAt,
            end_at: TestConstants.endAt,
            location_name: TestConstants.locationName,
            location_address: TestConstants.locationAddress
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testRequest() {
        let nestedObject = testee.request.body?.calendar_event
        XCTAssertEqual(nestedObject?.context_code, TestConstants.contextCode)
        XCTAssertEqual(nestedObject?.title, TestConstants.title)
        XCTAssertEqual(nestedObject?.description, TestConstants.description)
        XCTAssertEqual(nestedObject?.start_at, TestConstants.startAt)
        XCTAssertEqual(nestedObject?.end_at, TestConstants.endAt)
        XCTAssertEqual(nestedObject?.location_name, TestConstants.locationName)
        XCTAssertEqual(nestedObject?.location_address, TestConstants.locationAddress)
    }

    func testWrite() {
        let response = APICalendarEvent.make(
            id: TestConstants.responseId,
            title: TestConstants.responseTitle,
            start_at: TestConstants.responseStartAt,
            end_at: TestConstants.responseEndAt,
            description: TestConstants.responseDescription,
            location_name: TestConstants.responseLocationName,
            location_address: TestConstants.responseLocationAddress
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let model: CalendarEvent? = databaseClient.first(where: #keyPath(CalendarEvent.id), equals: TestConstants.responseId.rawValue)

        XCTAssertEqual(model?.title, TestConstants.responseTitle)
        XCTAssertEqual(model?.startAt, TestConstants.responseStartAt)
        XCTAssertEqual(model?.endAt, TestConstants.responseEndAt)
        XCTAssertEqual(model?.details, TestConstants.responseDescription)
        XCTAssertEqual(model?.locationName, TestConstants.responseLocationName)
        XCTAssertEqual(model?.locationAddress, TestConstants.responseLocationAddress)
    }
}
