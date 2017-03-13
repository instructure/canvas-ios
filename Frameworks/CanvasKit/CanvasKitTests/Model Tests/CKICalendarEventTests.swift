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

import XCTest

class CKICalendarEventTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        let calendarEventDictionary = Helpers.loadJSONFixture("calendar_event") as NSDictionary
        var calendarEvent = CKICalendarEvent(fromJSONDictionary: calendarEventDictionary)
        XCTAssertEqual(calendarEvent.id!, "1194491", "Calendar Event id was not parsed correctly")
        XCTAssertEqual(calendarEvent.title!, "Testing", "Calendar Event title was not parsed correctly")

        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        var date = formatter.dateFromString("2013-09-18T00:00:00-06:00")
        XCTAssertEqual(calendarEvent.startAt!, date, "Calendar Event startAt was not parsed correctly")
        XCTAssertEqual(calendarEvent.endAt!, date, "Calendar Event endAt was not parsed correctly")
        XCTAssertEqual(calendarEvent.description, "Secret Meeting of Super Persons", "Calendar Event description was not parsed correctly")
        XCTAssertEqual(calendarEvent.locationName!, "The Bat Cave", "Calendar Event locationName was not parsed correctly")
        XCTAssertEqual(calendarEvent.locationAddress!, "300 E Super Cool Dr", "Calendar Event locationAddress was not parsed correctly")
        XCTAssertEqual(calendarEvent.contextCode!, "user_4621806", "Calendar Event contextCode was not parsed correctly")
        XCTAssertEqual(calendarEvent.workflowState!, "active", "Calendar Event workflowState was not parsed correctly")
        XCTAssertFalse(calendarEvent.hidden, "Calendar Event hidden was not parsed correctly")
        XCTAssertEqual(calendarEvent.parentEventID!, "1", "Calendar Event parentEventID was not parsed correctly")
        XCTAssertEqual(calendarEvent.childEventsCount, 0, "Calendar Event childEventsCount was not parsed correctly")

        var url = NSURL(string:"https://mobiledev.instructure.com/api/v1/calendar_events/1194491")!
        XCTAssertEqual(calendarEvent.url!, url, "Calendar Event url was not parsed correctly")
        
        url = NSURL(string:"https://mobiledev.instructure.com/calendar?event_id=1194491&include_contexts=user_4621806#7b2273686f77223a2267726f75705f757365725f34363231383036227d")!
        XCTAssertEqual(calendarEvent.htmlURL!, url, "Calendar Event htmlURL was not parsed correctly")
        
        url = NSURL(string:"https://example.com/api/v1/appointment_groups/543")!
        XCTAssertEqual(calendarEvent.appointmentGroupURL!, url,"Calendar Event appointmentGroupURL was not parsed correctly")
        
        formatter.includeTime = false
        date = formatter.dateFromString("2013-09-18")
        XCTAssertEqual(calendarEvent.allDayDate!, date, "Calendar Event allDayDate was not parsed correctly")
        
        XCTAssert(calendarEvent.allDay, "Calendar Event allDay was not parsed correctly")

        formatter.includeTime = true
        date = formatter.dateFromString("2013-09-18T08:57:31-06:00")
        XCTAssertEqual(calendarEvent.createdAt!, date, "Calendar Event createdAt was not parsed correctly")
        XCTAssertEqual(calendarEvent.updatedAt!, date, "Calendar Event updatedAt was not parsed correctly")

        XCTAssertFalse(calendarEvent.reserved, "Calendar Event reserved was not parsed correctly")

        XCTAssertEqual(calendarEvent.appointmentGroupID!, "987","Calendar Event appointmentGroupID was not parsed correctly")

        XCTAssertFalse(calendarEvent.ownReservation, "Calendar Event ownReservation was not parsed correctly")
        
        XCTAssertEqual(calendarEvent.path!, "/api/v1/calendar_events/1194491", "Calendar Event path was not parsed correctly")
    }
}
