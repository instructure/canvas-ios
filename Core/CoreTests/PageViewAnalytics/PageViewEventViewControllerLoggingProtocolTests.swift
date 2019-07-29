//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import XCTest
@testable import Core

class PageViewEventViewControllerLoggingProtocolTests: XCTestCase {

    var start: Date!
    var end: Date!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var persistenceTestFileName = "PageViewEventViewControllerLoggingProtocolTests.dat"
    var waitExpectation: XCTestExpectation!
    var tearDownWait: XCTestExpectation!

    override func setUp() {
        super.setUp()
        end = Date()
        start = end.addMinutes(-1)

        Keychain.config = KeychainConfig(service: "com.instructure.service", accessGroup: nil)
        Keychain.clearEntries()

        waitExpectation = XCTestExpectation(description: "description")

        deletePageViewPersistenceTestFile(persistenceTestFileName)
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount, handler: nil)

        PageViewEventController.instance.persistency = p
        PageViewEventController.instance.configure(backgroundAppHelper: TestAppBackgroundHelper())
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testTracking() {

        let entry = KeychainEntry.make()
        Keychain.addEntry(entry)

        PageViewEventController.instance.appCanLogEvents = { return true }

        XCTAssertEqual(p.queueCount, 0)
        //  when
        Clock.mockNow(start)
        startTrackingTimeOnViewController()
        Clock.mockNow(end)
        stopTrackingTimeOnViewController(eventName: "\(#function)")

        dispatchQueue.async {
            self.waitExpectation.fulfill()
        }

        wait(for: [waitExpectation], timeout: 0.5)
        //  then
        let events = p.batchOfEvents(1)
        XCTAssertEqual(events?.count, 1)
        XCTAssertEqual(events?.first?.eventName, "\(#function)")
    }
}

extension PageViewEventViewControllerLoggingProtocolTests: PageViewEventViewControllerLoggingProtocol {}

class TestAppBackgroundHelper: AppBackgroundHelperProtocol {
    func startBackgroundTask(taskName: String) {

    }

    func endBackgroundTask() {

    }
}
