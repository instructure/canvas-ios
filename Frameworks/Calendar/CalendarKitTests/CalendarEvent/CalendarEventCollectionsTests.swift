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
@testable import SoPersistent
import CoreData
import TooLegit
import DoNotShipThis
import Result

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
                refresher.playback("calendar_events_list", in: currentBundle, with: session)
            }
        }
    }

}
