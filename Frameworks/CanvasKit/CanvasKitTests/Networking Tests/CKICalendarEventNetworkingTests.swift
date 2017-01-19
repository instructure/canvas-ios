//
//  CKICalendarEventNetworkingTests.swift
//  CanvasKit
//
//  Created by Nathan Lambson on 7/29/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
