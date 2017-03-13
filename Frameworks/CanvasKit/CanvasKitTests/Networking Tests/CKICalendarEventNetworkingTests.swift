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

class CKICalendarEventNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchCalendarEventsForContext() {
        let client = MockCKIClient()
        let courseDictionary = Helpers.loadJSONFixture("course") as NSDictionary
        let course = CKICourse(fromJSONDictionary: courseDictionary)
        let groupDictionary = Helpers.loadJSONFixture("group") as NSDictionary
        let group = CKICourse(fromJSONDictionary: groupDictionary)
        let userDictionary = Helpers.loadJSONFixture("user") as NSDictionary
        let user = CKICourse(fromJSONDictionary: userDictionary)
        
        client.fetchCalendarEventsForContext(course)
        client.fetchCalendarEventsForContext(group)
        client.fetchCalendarEventsForContext(user)
        XCTAssertEqual(client.capturedPath!, "/api/v1/calendar_events", "CKICalendarEvent returned API path for testFetchCalendarEventsForContext was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKICalendarEvent API Interaction Method was incorrect")
    }
    
    func testFetchCalendarEventsForToday() {
        let client = MockCKIClient()
        
        client.fetchCalendarEventsForToday()
        XCTAssertEqual(client.capturedPath!, "/api/v1/calendar_events", "CKICalendarEvent returned API path for testFetchCalendarEventsForToday was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKICalendarEvent API Interaction Method was incorrect")
    }

    func testFetchCalendarEventsFromTo() {
        let client = MockCKIClient()
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let start = formatter.dateFromString("2011-07-13T09:12:00Z")
        let end = formatter.dateFromString("2014-07-13T09:12:00Z")
        
        client.fetchCalendarEventsFrom(start, to: end)
        XCTAssertEqual(client.capturedPath!, "/api/v1/calendar_events", "CKICalendarEvent returned API path for testFetchCalendarEventsFromTo was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKICalendarEvent API Interaction Method was incorrect")
        XCTAssertEqual(client.capturedParameters!.count, 2, "CKICalendarEvent request parameters are incorrect")
    }
    
    func testFetchCalendarEvents() {
        let client = MockCKIClient()
        
        client.fetchCalendarEvents()
        XCTAssertEqual(client.capturedPath!, "/api/v1/calendar_events", "CKICalendarEvent returned API path for testFetchCalendarEvents was incorrect")
        XCTAssertEqual(client.capturedMethod!, MockCKIClient.Method.Fetch, "CKICalendarEvent API Interaction Method was incorrect")
    }
}
