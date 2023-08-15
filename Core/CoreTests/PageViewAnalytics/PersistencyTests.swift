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

class PersistencyTests: XCTestCase {

    let userID = "321"
    let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var waitExpectation = XCTestExpectation(description: "expectation")
    var persistenceTestFileName: String = ""

    override func setUp() {
        super.setUp()
        AppEnvironment.shared.currentSession = .init(baseURL: URL(string: "/")!, userID: userID, userName: "")
        waitExpectation = XCTestExpectation(description: "expectation")
        persistenceTestFileName = "pageViewTests-\(Foundation.UUID().uuidString).dat"
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount(for: userID), userID: userID, handler: nil)
        p.dequeue(p.queueCount(for: "another"), userID: "another", handler: nil)
        Clock.mockNow(date)
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testAddToQueue() {
        p.dequeue(p.queueCount(for: userID), userID: userID, handler: nil)
        XCTAssertEqual(p.queueCount(for: userID), 0)

        let e = PageViewEvent(eventName: "test", attributes: [:], userID: "321", timestamp: self.date, eventDuration: 0.05)
        let e2 = PageViewEvent(eventName: "test", attributes: [:], userID: "another", timestamp: self.date, eventDuration: 0.05)
        p.addToQueue(e)
        p.addToQueue(e2)

        drainMainQueue()

        waitExpectation.fulfill()
        wait(for: [waitExpectation], timeout: 5)
        XCTAssertEqual(p.queueCount(for: userID), 1)
    }

    func testBatchOfEvents() {
        p.dequeue(p.queueCount(for: userID), userID: userID, handler: nil)
        let a = PageViewEvent(eventName: "a", attributes: [:], userID: "321", timestamp: self.date, eventDuration: 0.05)
        let b = PageViewEvent(eventName: "b", attributes: [:], userID: "321", timestamp: self.date, eventDuration: 0.05)
        let c = PageViewEvent(eventName: "c", attributes: [:], userID: "321", timestamp: self.date, eventDuration: 0.05)
        let d = PageViewEvent(eventName: "d", attributes: [:], userID: "another", timestamp: self.date, eventDuration: 0.05)
        p.addToQueue(a)
        p.addToQueue(b)
        p.addToQueue(c)
        p.addToQueue(d)

        drainMainQueue()

        waitExpectation.fulfill()
        wait(for: [waitExpectation], timeout: 5)

        XCTAssertEqual(p.queueCount(for: userID), 3)

        let batch1 = p.batchOfEvents(4, userID: userID)
        XCTAssertNil(batch1, "batch1 count: \(String(describing: batch1?.count))")

        let batch2 = p.batchOfEvents(3, userID: userID)
        XCTAssertEqual(batch2?.count, 3)
    }
}

func deletePageViewPersistenceTestFile(_ filename: String) {
    let fileManager = FileManager.default
    let appSupportDirectoryURL = FileManager.appSupportDirectory()
    if let URL = appSupportDirectoryURL {
        let deleteURL = URL.appendingPathComponent(filename)
        do {
            try fileManager.removeItem(at: deleteURL)
        } catch {
            print()
        }
    }
}
