//
//  CalendarKitTests.swift
//  CalendarKitTests
//
//  Created by Brandon Pluim on 1/15/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
import SoAutomated
@testable import CalendarKit
import CoreData
import DVR
import TooLegit

struct DateRange {
    let start: String
    let end: String
    private let formatter: NSDateFormatter

    var startDate: NSDate {
        return formatter.dateFromString(start)!
    }

    var endDate: NSDate {
        return formatter.dateFromString(end)!
    }

    init(start: String, end: String) {
        self.start = start
        self.end = end
        formatter = NSDateFormatter()
        formatter.dateFormat = "YYY-MM-dd"
    }
}

class CalendarKitTests: XCTestCase {

    var session = Session.inMemory
    var managedObjectContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        managedObjectContext = try! session.calendarEventsManagedObjectContext()
    }

    var dayDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()

    var ISO8601DateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter
    }()

    func IS8601StringFromDayDate(dayDate: String) -> String {
        return ISO8601DateFormatter.stringFromDate(dayDateFormatter.dateFromString(dayDate)!)
    }

    func loadDummyData(inContext context: NSManagedObjectContext) -> [String: CalendarEvent] {
        var date = self.dayDateFormatter.dateFromString("2016-01-01")!
        let jan = CalendarEvent.build(context,
                                      title: "New Years",
                                      startAt: date,
                                      endAt: date,
                                      allDayDate: self.dayDateFormatter.stringFromDate(date),
                                      contextCode: "code_get_the_car"
        )

        date = self.dayDateFormatter.dateFromString("2016-02-01")!
        let feb = CalendarEvent.build(context,
                                      title: "First day of Feb",
                                      startAt: date,
                                      endAt: date,
                                      allDayDate: self.dayDateFormatter.stringFromDate(date),
                                      contextCode: "code_feb"
        )

        date = self.dayDateFormatter.dateFromString("2016-06-01")!
        let jun = CalendarEvent.build(context,
                                      title: "First day of June",
                                      startAt: date,
                                      endAt: date,
                                      allDayDate: self.dayDateFormatter.stringFromDate(date),
                                      contextCode: "code_get_the_car"
        )

        date = self.dayDateFormatter.dateFromString("2016-12-01")!
        let dec = CalendarEvent.build(context,
                                      title: "First day of Dec",
                                      startAt: date,
                                      endAt: date,
                                      allDayDate: self.dayDateFormatter.stringFromDate(date),
                                      contextCode: "code_get_the_car"
        )

        return [
            "jan": jan,
            "feb": feb,
            "jun": jun,
            "dec": dec
        ]
    }
}
