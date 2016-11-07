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
