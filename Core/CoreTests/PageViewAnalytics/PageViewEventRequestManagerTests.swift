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

class PageViewEventRequestManagerTests: CoreTestCase {
    let userID = "321"
    let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var persistenceTestFileName = "pageViewRequestManagerTests.dat"
    var expectation = XCTestExpectation(description: "expectation")
    var requestManager: PageViewEventRequestManager!
    let backgroundHelper = TestAppBackgroundHelper()

    override func setUp() {
        super.setUp()
        environment.currentSession = .make(userID: userID)
        expectation = XCTestExpectation(description: "expectation")
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-requestmanager-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount(for: userID), userID: userID, handler: nil)
        Clock.mockNow(date)

        requestManager = PageViewEventRequestManager(persistence: p, env: environment)
        requestManager.backgroundAppHelper = backgroundHelper
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testRetrievePandataEndpointInfo() {
        let keychain = Keychain(serviceName: Pandata.tokenKeychainService)
        keychain.removeData(for: Pandata.tokenKeychainKey)

        let token = "token"
        //  mock pandata endpoint req
        let tokenReq = PostPandataEventsTokenRequest()
        let tokenResponse = APIPandataEventsToken(url: URL(string: "https://localhost/prod/pandata-event")!, auth_token: token, props_token: "propsToken", expires_at: 1563637743086.64)
        api.mock(tokenReq, value: tokenResponse, response: nil, error: nil)

        //  events
        let a = PageViewEvent(eventName: "a", attributes: [:], userID: "321", timestamp: date, eventDuration: 0.05)
        let b = PageViewEvent(eventName: "b", attributes: [:], userID: "321", timestamp: date, eventDuration: 0.05)
        let addEvents = XCTestExpectation(description: "events added")
        addEvents.expectedFulfillmentCount = 2
        p.addToQueue(a, completionHandler: addEvents.fulfill)
        p.addToQueue(b, completionHandler: addEvents.fulfill)
        wait(for: [addEvents], timeout: 5)

        let pandataEvents = p.batchOfEvents(2, userID: userID)?.map { $0.apiEvent(tokenResponse) } ?? []

        // mock the send events req
        api.mock(PostPandataEventsRequest(token: tokenResponse, events: pandataEvents), data: "\"ok\"".data(using: .utf8))

        drainMainQueue()
        XCTAssertEqual(p.queueCount(for: userID), 2)

        requestManager.sendEvents { (error) in
            XCTAssertNil(error)
            self.expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        XCTAssertEqual(p.queueCount(for: userID), 0)
        XCTAssertEqual(["start", "end"], backgroundHelper.tasks["fetch pandata token"])
        XCTAssertEqual(["start", "end"], backgroundHelper.tasks["send pageview events"])
    }

    func testCleanup() {
        let keychain = Keychain(serviceName: Pandata.tokenKeychainService)
        let added = keychain.setData("foobar".data(using: .utf8)!, for: Pandata.tokenKeychainKey)
        XCTAssertTrue(added)

        if let data = keychain.getData(for: Pandata.tokenKeychainKey), let value = String(data: data, encoding: .utf8) {
            XCTAssertNotNil(value)
        } else {
            XCTFail()
        }

        requestManager.cleanup()

        let data = keychain.getData(for: Pandata.tokenKeychainKey)
        XCTAssertNil(data)
    }
}
