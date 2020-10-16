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

    let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var waitExpectation = XCTestExpectation(description: "expectation")
    var persistenceTestFileName: String = ""

    override func setUp() {
        super.setUp()
        waitExpectation = XCTestExpectation(description: "expectation")
        persistenceTestFileName = "pageViewTests-\(Foundation.UUID().uuidString).dat"
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount, handler: nil)
        Clock.mockNow(date)
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testAddToQueue() {

        dispatchQueue.async {
            self.p.dequeue(self.p.queueCount, handler: nil)

            XCTAssertEqual(self.p.queueCount, 0)

            let e = PageViewEvent(eventName: "test", attributes: [:], userID: "1", timestamp: self.date, eventDuration: 0.05)
            self.p.addToQueue(e)

            self.dispatchQueue.async {
                self.waitExpectation.fulfill()
            }
        }
        self.wait(for: [self.waitExpectation], timeout: 5)
        XCTAssertEqual(self.p.queueCount, 1)
    }

    func testBatchOfEvents() {

        dispatchQueue.async {
            self.p.dequeue(self.p.queueCount, handler: nil)
            let a = PageViewEvent(eventName: "a", attributes: [:], userID: "1", timestamp: self.date, eventDuration: 0.05)
            let b = PageViewEvent(eventName: "b", attributes: [:], userID: "1", timestamp: self.date, eventDuration: 0.05)
            let c = PageViewEvent(eventName: "c", attributes: [:], userID: "1", timestamp: self.date, eventDuration: 0.05)
            self.p.addToQueue(a)
            self.p.addToQueue(b)
            self.p.addToQueue(c)

            self.dispatchQueue.async {
                self.waitExpectation.fulfill()
            }
        }
        wait(for: [waitExpectation], timeout: 5)

        XCTAssertEqual(p.queueCount, 3)

        let batch1 = p.batchOfEvents(4)
        XCTAssertNil(batch1, "batch1 count: \(String(describing: batch1?.count))")

        let batch2 = p.batchOfEvents(3)
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
