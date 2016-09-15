//
//  CalendarEventCollectionsTests.swift
//  Calendar
//
//  Created by Nathan Armstrong on 3/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
@testable import CalendarKit
import SoAutomated
@testable import SoPersistent
import CoreData
import TooLegit
import DoNotShipThis
import Result

class DescribeTableViewController: CalendarKitTests {

    /**
     Acceptance Criteria:
        * it only shows events within a specified date range
        * it only shows events with certain context codes
        * it sections the events by date
        * it sorts the events by date within their sections
        * it can be refreshed
    */

    var refreshCassette: Fixture!

    let tvc = CalendarEvent.TableViewController()
    let vmFactory: CalendarEvent->SimpleCalendarEventDVM = { return SimpleCalendarEventDVM(title: $0.title!) }

    override func setUp() {
        super.setUp()
        session = Session.nas
        managedObjectContext = try! session.calendarEventsManagedObjectContext()
        refreshCassette = "calendar_events_list"

        let _ = tvc.view // trigger viewDidLoad
    }

    func test_itOnlyShowsEventsForDateRange() {
        var range: DateRange
        var collection: FetchedCollection<CalendarEvent>
        let data = loadDummyData(inContext: managedObjectContext)
        let jan = data["jan"]!
        let feb = data["feb"]!
        let jun = data["jun"]!
        let dec = data["dec"]!
        let contextCodes = [jan, feb, jun, dec].map { $0.contextCode }

        // jan
        range = DateRange(start: "2016-01-01", end: "2016-01-02")
        collection = collectionByDueDate(range, contextCodes: contextCodes)
        tvc.prepare(collection, refresher: nil, viewModelFactory: vmFactory)
        assertTableViewLooksLike([[jan.title!]])

        // feb - jun
        range = DateRange(start: "2016-02-01", end: "2016-06-30")
        collection = collectionByDueDate(range, contextCodes: contextCodes)
        tvc.prepare(collection, refresher: nil, viewModelFactory: vmFactory)
        assertTableViewLooksLike([[feb.title!], [jun.title!]])

        // jan - dec
        range = DateRange(start: "2016-01-01", end: "2016-12-31")
        collection = collectionByDueDate(range, contextCodes: contextCodes)
        tvc.prepare(collection, refresher: nil, viewModelFactory: vmFactory)
        assertTableViewLooksLike([[jan.title!], [feb.title!], [jun.title!], [dec.title!]])
    }

    func assertTableViewLooksLike(sections: [[String]]) {
        XCTAssertEqual(sections.count, tvc.tableView.numberOfSections)
        for (s, rows) in sections.enumerate() {
            XCTAssertEqual(rows.count, tvc.tableView.numberOfRowsInSection(s))
            for (r, title) in rows.enumerate() {
                let cell = tvc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: r, inSection: s))
                XCTAssertEqual(title, cell?.textLabel?.text)
            }
        }
    }

    // MARK: Helpers

    func collectionByDueDate(dateRange: DateRange, contextCodes: [String]) -> FetchedCollection<CalendarEvent> {
        return try! CalendarEvent.collectionByDueDate(session, startDate: dateRange.startDate, endDate: dateRange.endDate, contextCodes: contextCodes)
    }

    func refresherByDueDate(dateRange: DateRange, contextCodes: [String]) -> Refresher {
        return try! CalendarEvent.refresher(session, startDate: dateRange.startDate, endDate: dateRange.endDate, contextCodes: contextCodes)
    }
}

class DescribeCollectionsPredicate: CalendarKitTests {

    var data: LazyMapCollection<Dictionary<String, CalendarEvent>, CalendarEvent>!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.calendarEventsManagedObjectContext()
        data = loadDummyData(inContext: managedObjectContext).values
    }

    func test_itFiltersByDateRange() {
        let start = self.dayDateFormatter.dateFromString("2016-01-01")!
        let end = self.dayDateFormatter.dateFromString("2016-06-30")!
        let codes = ["code_get_the_car", "code_feb"]
        let predicate = CalendarEvent.predicate(start, endDate: end, contextCodes: codes)

        let results = data.filter(predicate.evaluateWithObject)

        XCTAssertEqual(3, results.count)
    }

    func test_itFiltersByContextCode() {
        let start = self.dayDateFormatter.dateFromString("2016-01-01")!
        let end = self.dayDateFormatter.dateFromString("2016-12-30")!
        let code = "code_get_the_car"
        let allOf2016 = CalendarEvent.predicate(start, endDate: end, contextCodes: [code])

        let results = data.filter(allOf2016.evaluateWithObject)

        XCTAssertEqual(3, results.count)
    }

    func testRefresher() {
        attempt {
            let session = Session.nas
            let context = try session.calendarEventsManagedObjectContext()
            let range = DateRange(start: "2016-01-01", end: "2016-03-01")
            let contextCodes: [String] = []
            let refresher = try CalendarEvent.refresher(session, startDate: range.startDate, endDate: range.endDate, contextCodes: contextCodes)

            assertDifference({ CalendarEvent.count(inContext: context) }, 2) {
                stub(session, "calendar_events_list") { expectation in
                    refresher.refreshingCompleted.observeNext { error in
                        self.refreshCompletedWithExpectation(expectation)(error)
                    }
                    refresher.refresh(true)
                }
            }
        }
    }

}
