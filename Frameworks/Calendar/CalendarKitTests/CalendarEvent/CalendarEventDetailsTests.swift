//
//  CalendarEventDetailsTests.swift
//  Calendar
//
//  Created by Nathan Armstrong on 3/11/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
@testable import CalendarKit
import SoAutomated
import SoPersistent
import CoreData
import DoNotShipThis
import TooLegit

class DescribeDetailViewController: XCTestCase {

    /**
     Acceptance Criteria:
        * it displays local details
        * it refreshes details from the server
        * it reflects managed object updates
    */

    var session = Session.nas
    var vc: CalendarEvent.DetailViewController!
    var calendarEvent: CalendarEvent!
    var observer: ManagedObjectObserver<CalendarEvent>!
    let detailsFactory: CalendarEvent->[SimpleCalendarEventDVM] = { return [SimpleCalendarEventDVM(title: $0.title ?? "empty")] }
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = try! session.calendarEventsManagedObjectContext()
        calendarEvent = CalendarEvent.build(context, id: "2724235")
        calendarEvent.title = "DetailViewController Test"
        try! context.save()

        observer = try! CalendarEvent.observer(session, calendarEventID: calendarEvent.id)
        let dataSource = try! CalendarEvent.detailsTableViewDataSource(session, calendarEventID: calendarEvent.id, detailsFactory: detailsFactory)
        vc = CalendarEvent.DetailViewController(dataSource: dataSource, refresher: nil)
        let _ = vc.view // trigger viewDidLoad
        vc.prepare(observer, refresher: nil, detailsFactory: detailsFactory)
    }

    func test_itDisplaysLocalDetails() {
        let tableView = vc.tableView
        let titleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual("DetailViewController Test", titleCell?.textLabel?.text)
    }

    func test_itRefreshesDetails() {
        stub(session, "calendar_event_details") { expectation in
            let refresher = try! CalendarEvent.refresher(self.session, calendarEventID: self.calendarEvent.id)
            self.vc.refresher = refresher

            refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
            refresher.refresh(true)
        }

        context.refreshAllObjects()
        let titleCell = vc.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertNotEqual("DetailViewController Test", titleCell?.textLabel?.text)
        XCTAssertNotEqual("DetailViewController Test", calendarEvent.title)
    }
}
