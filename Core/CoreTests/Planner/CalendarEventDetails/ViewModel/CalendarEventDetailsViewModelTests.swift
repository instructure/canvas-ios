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

@testable import Core
import Combine
import XCTest

class CalendarEventDetailsViewModelTests: CoreTestCase {
    let mockInteractor = CalendarEventDetailsInteractorMock()

    override func setUp() {
        super.setUp()
        mockInteractor.mockEvent = nil
        mockInteractor.mockColor = nil
    }

    func testEventDateFormatting() {
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = startDate.addMinutes(60)
        let event: CalendarEvent = databaseClient.insert()
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        event.isAllDay = true
        event.startAt = startDate
        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)
        var expectedDate = startDate.dateOnlyString
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))

        event.isAllDay = false
        event.startAt = startDate
        event.endAt = endDate
        testee.reload {}
        expectedDate = startDate.intervalStringTo(endDate)
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))

        event.isAllDay = false
        event.startAt = startDate
        event.endAt = nil
        testee.reload {}
        expectedDate = startDate.dateTimeString
        XCTAssertTrue(testee.date!.hasPrefix("\(expectedDate)\n"))
    }

    func testEventSeriesInfo() {
        let startDate = Date(timeIntervalSince1970: 0)
        let event: CalendarEvent = databaseClient.insert()
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        event.startAt = startDate
        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)
        XCTAssertTrue(testee.date!.hasSuffix("\nDoes Not Repeat"))

        event.seriesInNaturalLanguage = "Weekly"
        testee.reload {}
        XCTAssertTrue(testee.date!.hasSuffix("\nRepeats Weekly"))
    }

    func testLocationInfo() {
        let event: CalendarEvent = databaseClient.insert()
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        event.locationName = "test location"
        event.locationAddress = "test address"
        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Location",
                description: "test location",
                isRichContent: false
            ),
            .init(
                title: "Address",
                description: "test address",
                isRichContent: false
            )
        ])

        event.locationName = ""
        event.locationAddress = "test address"
        testee.reload {}
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Address",
                description: "test address",
                isRichContent: false
            )
        ])

        event.locationName = "test location"
        event.locationAddress = ""
        testee.reload {}
        XCTAssertEqual(testee.locationInfo, [
            .init(
                title: "Location",
                description: "test location",
                isRichContent: false
            )
        ])
    }

    func testEventDetails() {
        let event: CalendarEvent = databaseClient.insert()
        event.details = "test details"
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)
        XCTAssertEqual(testee.details, .init(title: "Details",
                                             description: "test details",
                                             isRichContent: true))
    }

    func testOtherProperties() {
        let event: CalendarEvent = databaseClient.insert()
        event.title = "test title"
        event.contextName = "test context"
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)

        XCTAssertEqual(testee.pageTitle, "Event Details")
        XCTAssertEqual(testee.pageSubtitle, "test context")
        XCTAssertEqual(testee.contextColor, .red)
        XCTAssertEqual(testee.title, "test title")
        XCTAssertEqual(testee.pageViewEvent, .init(eventName: "/calendar"))
    }

    func testStates() {
        let event: CalendarEvent = databaseClient.insert()
        mockInteractor.mockEvent = event
        mockInteractor.mockColor = .red

        let testee = CalendarEventDetailsViewModel(interactor: mockInteractor)
        XCTAssertEqual(testee.state, .data)

        mockInteractor.mockEvent = nil
        testee.reload {}
        XCTAssertEqual(testee.state, .error)
    }
}

class CalendarEventDetailsInteractorMock: CalendarEventDetailsInteractor {
    var mockEvent: CalendarEvent?
    var mockColor: UIColor?

    func getCalendarEvent(
        ignoreCache: Bool
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error> {
        guard let mockEvent, let mockColor else {
            return Fail(error: NSError.internalError())
        }
        return Just((event: mockEvent, contextColor: mockColor))
            .setFailureType(to: Error.self)
    }
}
