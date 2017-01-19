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

class DescribeSessionManagedObjectContexts: XCTestCase {
    let session = Session.inMemory

    func test_itHasACalendarEventsContext() {
        let context = try! session.calendarEventsManagedObjectContext()

        XCTAssertEqual(1, session.contextsByStoreID.count)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType, context.concurrencyType)
        guard let psc = context.persistentStoreCoordinator else {
            XCTFail("no psc")
            return
        }
        XCTAssertEqual(["CalendarEvent"], psc.managedObjectModel.entities.map { $0.name ?? "" })
    }

    func test_itHasAnObserveeCalendarEventsContext() {
        let context = try! session.calendarEventsManagedObjectContext("1")

        XCTAssertEqual(1, session.contextsByStoreID.count)
        XCTAssertEqual(NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType, context.concurrencyType)
        guard let psc = context.persistentStoreCoordinator else {
            XCTFail("no psc")
            return
        }
        XCTAssertEqual(["CalendarEvent"], psc.managedObjectModel.entities.map { $0.name ?? "" })
    }

}
