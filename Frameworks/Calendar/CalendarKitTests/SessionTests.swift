//
//  SessionTests.swift
//  Calendar
//
//  Created by Nathan Armstrong on 3/14/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
@testable import CalendarKit
import SoAutomated
@testable import SoPersistent
import CoreData
import TooLegit

class DescribeSessionManagedObjectContexts: XCTestCase {
    let session = Session.inMemory

    func test_itHasACalendarEventsContext() {
        let context = try! session.calendarEventsManagedObjectContext()

        XCTAssertEqual(1, session.contextsByStoreID.count)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, context.concurrencyType)
        guard let psc = context.persistentStoreCoordinator else {
            XCTFail("no psc")
            return
        }
        XCTAssertEqual(["CalendarEvent"], psc.managedObjectModel.entities.map { $0.name ?? "" })
    }

    func test_itHasAnObserveeCalendarEventsContext() {
        let context = try! session.calendarEventsManagedObjectContext("1")

        XCTAssertEqual(1, session.contextsByStoreID.count)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType, context.concurrencyType)
        guard let psc = context.persistentStoreCoordinator else {
            XCTFail("no psc")
            return
        }
        XCTAssertEqual(["CalendarEvent"], psc.managedObjectModel.entities.map { $0.name ?? "" })
    }

}
