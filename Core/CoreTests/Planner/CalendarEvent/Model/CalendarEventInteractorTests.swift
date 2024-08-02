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

final class CalendarEventInteractorTests: CoreTestCase {

    private enum TestConstants {
        static let contextCode = "some contextCode"
        static let title = "some title"
        static let description = "some description"
        static let startAt = Clock.date(year: 2024, month: 1, day: 1, hour: 3)
        static let endAt = startAt.addHours(2)
        static let locationName = "some locationName"
        static let locationAddress = "some locationAddress"
    }

    var testee: CalendarEventInteractorLive!

    override func setUp() {
        super.setUp()
        testee = .init()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - GetCalendarEvent

    func testLoadsEventData() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        let mockAPIColor = "#FF0000"
        api.mock(GetCustomColorsRequest(),
                 value: .init(custom_colors: [mockAPIEvent.context_code: mockAPIColor]))
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: mockAPIEvent)

        XCTAssertFirstValueAndCompletion(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue)) { (event, color) in
            XCTAssertEqual(color, UIColor(hexString: mockAPIColor))
            XCTAssertEqual(event.id, mockAPIEvent.id.rawValue)
        }
    }

    func testLoadFailsIfEventNotReceived() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        let mockAPIColor = "#FF0000"
        api.mock(GetCustomColorsRequest(),
                 value: .init(custom_colors: [mockAPIEvent.context_code: mockAPIColor]))
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: nil)

        XCTAssertFailure(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue))
    }

    func testLoadsEventIfColorAPIFails() {
        let mockAPIEvent: APICalendarEvent = .make(id: "testEventID")
        api.mock(GetCustomColorsRequest(),
                 error: NSError.internalError())
        api.mock(GetCalendarEventRequest(eventID: mockAPIEvent.id.rawValue),
                 value: mockAPIEvent)

        XCTAssertFirstValueAndCompletion(testee.getCalendarEvent(id: mockAPIEvent.id.rawValue)) { (event, color) in
            XCTAssertEqual(color, UIColor.ash)
            XCTAssertEqual(event.id, mockAPIEvent.id.rawValue)
        }
    }

    // MARK: - GetManageCalendarPermission

    func testGetManageCalendarPermissionWhenItsTrue() {
        let context: Context = .course("42")
        let request = GetContextPermissionsRequest(context: context, permissions: [.manageCalendar])
        api.mock(request, value: .make(manage_calendar: true, manage_groups: false))

        XCTAssertFirstValueAndCompletion(testee.getManageCalendarPermission(context: context, ignoreCache: false)) { permission in
            XCTAssertEqual(permission, true)
        }
    }

    func testGetManageCalendarPermissionWhenItsFalse() {
        let context: Context = .course("42")
        let request = GetContextPermissionsRequest(context: context, permissions: [.manageCalendar])
        api.mock(request, value: .make(manage_calendar: false, manage_groups: true))

        XCTAssertFirstValueAndCompletion(testee.getManageCalendarPermission(context: context, ignoreCache: false)) { permission in
            XCTAssertEqual(permission, false)
        }
    }

    func testGetManageCalendarPermissionWhenItsNil() {
        let context: Context = .course("42")
        let request = GetContextPermissionsRequest(context: context, permissions: [.manageCalendar])
        api.mock(request, value: .make(manage_calendar: nil))

        XCTAssertFirstValueAndCompletion(testee.getManageCalendarPermission(context: context, ignoreCache: false)) { permission in
            XCTAssertEqual(permission, false)
        }
    }

    // MARK: - CreateEvent

    func testCreateEventParametersUseCaseProperly() {
        verifyCreateEvent(
            model: .make(
                title: TestConstants.title,
                date: TestConstants.startAt.startOfDay(),
                isAllDay: false,
                startTime: TestConstants.startAt,
                endTime: TestConstants.endAt,
                contextCode: TestConstants.contextCode,
                location: TestConstants.locationName,
                address: TestConstants.locationAddress,
                details: TestConstants.description
            )
        ) { body in
            XCTAssertEqual(body.calendar_event.context_code, TestConstants.contextCode)
            XCTAssertEqual(body.calendar_event.title, TestConstants.title)
            XCTAssertEqual(body.calendar_event.description, TestConstants.description)
            XCTAssertEqual(body.calendar_event.start_at, TestConstants.startAt)
            XCTAssertEqual(body.calendar_event.end_at, TestConstants.endAt)
            XCTAssertEqual(body.calendar_event.location_name, TestConstants.locationName)
            XCTAssertEqual(body.calendar_event.location_address, TestConstants.locationAddress)
        }
    }

    private func verifyCreateEvent(
        model: CalendarEventRequestModel,
        bodyHandler: @escaping (PostCalendarEventRequest.Body) -> Void
    ) {
        let request = PostCalendarEventRequest(body: .make())
        let expectation = XCTestExpectation(description: "Request was sent")
        mockRequest(request) { (body: PostCalendarEventRequest.Body) in
            bodyHandler(body)
            expectation.fulfill()
        }

        let publisher = testee.createEvent(model: model)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - UpdateEvent

    func testUpdateEventParametersUseCaseProperly() {
        verifyUpdateEvent(
            model: .make(
                title: TestConstants.title,
                date: TestConstants.startAt.startOfDay(),
                isAllDay: false,
                startTime: TestConstants.startAt,
                endTime: TestConstants.endAt,
                contextCode: TestConstants.contextCode,
                location: TestConstants.locationName,
                address: TestConstants.locationAddress,
                details: TestConstants.description
            )
        ) { body in
            XCTAssertEqual(body.calendar_event.context_code, TestConstants.contextCode)
            XCTAssertEqual(body.calendar_event.title, TestConstants.title)
            XCTAssertEqual(body.calendar_event.description, TestConstants.description)
            XCTAssertEqual(body.calendar_event.start_at, TestConstants.startAt)
            XCTAssertEqual(body.calendar_event.end_at, TestConstants.endAt)
            XCTAssertEqual(body.calendar_event.location_name, TestConstants.locationName)
            XCTAssertEqual(body.calendar_event.location_address, TestConstants.locationAddress)
        }
    }

    private func verifyUpdateEvent(
        model: CalendarEventRequestModel,
        bodyHandler: @escaping (PutCalendarEventRequest.Body) -> Void
    ) {
        let request = PutCalendarEventRequest(id: "42", body: .make())
        let expectation = XCTestExpectation(description: "Request was sent")
        mockRequest(request) { (body: PutCalendarEventRequest.Body) in
            bodyHandler(body)
            expectation.fulfill()
        }

        let publisher = testee.updateEvent(id: "42", model: model)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - DeleteEvent

    func testDeleteEvent() {
        let request = DeleteCalendarEventRequest(id: "42", body: .make())
        let expectation = XCTestExpectation(description: "Request was sent")
        api.mock(request) { _ in
            expectation.fulfill()
            return (nil, nil, nil)
        }

        let publisher = testee.deleteEvent(id: "42", seriesModificationType: nil)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - isRequestModelValid

    func testIsRequestModelValid() {
        var model: CalendarEventRequestModel

        model = .make(title: "something", isAllDay: true)
        XCTAssertEqual(model.isValid, true)
        XCTAssertEqual(testee.isRequestModelValid(model), true)

        model = .make(title: "")
        XCTAssertEqual(model.isValid, false)
        XCTAssertEqual(testee.isRequestModelValid(model), false)

        XCTAssertEqual(testee.isRequestModelValid(nil), false)
    }

    // MARK: - Helpers

    private func mockRequest<Request: APIRequestable, Body: Codable & Equatable>(
        _ request: Request,
        dataHandler: @escaping (Body) -> Void
    ) {
        api.mock(request) { urlRequest in
            guard let body: Body = urlRequest.decodeBody() else {
                XCTFail("Request body decoding failure")
                return (nil, nil, nil)
            }
            dataHandler(body)
            return (nil, nil, nil)
        }
    }
}
