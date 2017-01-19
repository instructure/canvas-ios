//
// Copyright (C) 2016-present Instructure, Inc.
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
    
    

import Foundation
@testable import CalendarKit
import SoAutomated
import Marshal
import ReactiveSwift
import DoNotShipThis
import TooLegit
import Nimble

let currentBundle = Bundle(for: CalendarEventNetworkTests.self)

class CalendarEventNetworkTests: XCTestCase {
    func test_itCanGetAnEvent() {
        var json: JSONObject?
        let session = Session.nas

        session.playback("calendar_event_details", in: currentBundle) {
            waitUntil { done in
                try! CalendarEvent.getCalendarEvent(session, calendarEventID: "2724235").startWithCompletedAction(done) { json = $0 }
            }
        }

        XCTAssertNotNil(json)
    }

    func test_itCanGetAListOfEvents() {
        let session = Session.nas
        let range = DateRange(start: "2016-01-01", end: "2016-03-01")
        let contextCodes: [String] = []

        session.playback("calendar_events_list", in: currentBundle) {
            waitUntil { done in
                try! CalendarEvent.getAllCalendarEvents(session, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes)
                    .concat(try! CalendarEvent.getCalendarEvents(session, type:.assignment, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes))
                    .concat(try! CalendarEvent.getCalendarEvents(session, type: .event, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes))
                    .startWithCompletedAction(done)
            }
        }
    }
}
