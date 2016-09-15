//
//  CalendarEventNetworkTests.swift
//  Calendar
//
//  Created by Nathan Armstrong on 3/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
@testable import CalendarKit
import SoAutomated
import Marshal
import ReactiveCocoa
import DoNotShipThis
import TooLegit

extension String: Fixture {
    public var name: String { return self }
    public var bundle: NSBundle { return NSBundle(forClass: CalendarEventNetworkTests.self) }
}

class CalendarEventNetworkTests: XCTestCase {
    func test_itCanGetAnEvent() {
        var json: JSONObject?
        let session = Session.nas

        stub(session, "calendar_event_details") { expectation in
            try! CalendarEvent.getCalendarEvent(session, calendarEventID: "2724235")
                .start { event in
                    switch event {
                    case .Next(let value): json = value
                    case .Completed: expectation.fulfill()
                    default: break
                    }
                }
        }

        XCTAssertNotNil(json)
    }

    func test_itCanGetAListOfEvents() {
        let session = Session.nas
        let range = DateRange(start: "2016-01-01", end: "2016-03-01")
        let contextCodes: [String] = []

        stub(session, "calendar_events_list") { expectation in
            try! CalendarEvent.getAllCalendarEvents(session, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes)
                .concat(try! CalendarEvent.getCalendarEvents(session, type: .Assignment, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes))
                .concat(try! CalendarEvent.getCalendarEvents(session, type: .Event, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes))
                .startWithCompleted { expectation.fulfill() }
        }
    }
}
