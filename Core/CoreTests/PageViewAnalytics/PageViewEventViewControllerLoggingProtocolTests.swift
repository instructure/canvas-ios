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
import TestsFoundation
@testable import Core

class PageViewEventViewControllerLoggingProtocolTests: XCTestCase {
    let userID = "321"
    var start: Date!
    var end: Date!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var persistenceTestFileName = "PageViewEventViewControllerLoggingProtocolTests.dat"
    var waitExpectation: XCTestExpectation!
    var screenViewTracker: ScreenViewTracker!
    var tearDownWait: XCTestExpectation!

    override func setUp() {
        super.setUp()
        end = Date()
        start = end.addMinutes(-1)

        LoginSession.clearAll()

        waitExpectation = XCTestExpectation(description: "description")

        deletePageViewPersistenceTestFile(persistenceTestFileName)
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount(for: userID), userID: userID, handler: nil)

        PageViewEventController.instance.persistency = p
        PageViewEventController.instance.configure(backgroundAppHelper: TestAppBackgroundHelper())
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testTracking() {

        let entry = LoginSession.make(userID: userID)
        LoginSession.add(entry)

        screenViewTracker = ScreenViewTrackerLive(
            parameters: ScreenViewTrackingParameters(eventName: "\(#function)")
        )
        PageViewEventController.instance.appCanLogEvents = { return true }

        XCTAssertEqual(p.queueCount(for: userID), 0)
        //  when
        Clock.mockNow(start)
        screenViewTracker.startTrackingTimeOnViewController()
        Clock.mockNow(end)
        screenViewTracker.stopTrackingTimeOnViewController()

        dispatchQueue.async {
            self.waitExpectation.fulfill()
        }

        wait(for: [waitExpectation], timeout: 0.5)
        //  then
        let events = p.batchOfEvents(1, userID: userID)
        XCTAssertEqual(events?.count, 1)
        XCTAssertEqual(events?.first?.eventName, "\(#function)")
    }
}

class TestAppBackgroundHelper: AppBackgroundHelperProtocol {
    var tasks: [String: [String]] = [:]
    func startBackgroundTask(taskName: String) {
        append("start", to: taskName)
    }

    func endBackgroundTask(taskName: String) {
        append("end", to: taskName)
    }

    private func append(_ event: String, to taskName: String) {
        var events = tasks[taskName] ?? []
        events.append(event)
        tasks[taskName] = events
    }
}
