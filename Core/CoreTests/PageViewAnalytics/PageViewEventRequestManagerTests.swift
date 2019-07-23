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
    let date = Date(fromISOString: "2019-06-25T06:00:00Z")!
    var dispatchQueue: DispatchQueue!
    var p: Persistency!
    var persistenceTestFileName = "pageViewRequestManagerTests.dat"
    var expectation = XCTestExpectation(description: "expectation")
    var writeWait1 = XCTestExpectation(description: "expectation")
    var requestManager: PageViewEventRequestManager!

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        writeWait1 = XCTestExpectation(description: "expectation")
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        Persistency.persistencyFileName = persistenceTestFileName
        dispatchQueue = DispatchQueue(label: "test-pageviewevents-requestmanager-queue", attributes: .concurrent)
        p = Persistency(dispatchQueue: dispatchQueue)
        p.dequeue(p.queueCount, handler: nil)
        Clock.mockNow(date)

        requestManager = PageViewEventRequestManager(persistence: p, api: api)
    }

    override func tearDown() {
        Clock.reset()
        deletePageViewPersistenceTestFile(persistenceTestFileName)
        super.tearDown()
    }

    func testRetrievePandataEndpointInfo() {
        let keychain = GeneralPurposeKeychain(serviceName: Pandata.tokenKeychainService)
        keychain.removeItem(for: Pandata.tokenKeychainKey)

        let token = "token"
        //  mock pandata endpoint req
        let tokenReq = PostPandataEventsTokenRequest()
        let tokenResponse = APIPandataEventsToken(url: URL(string: "https://localhost/prod/pandata-event")!, auth_token: token, props_token: "propsToken", expires_at: 1563637743086.64)
        api.mock(tokenReq, value: tokenResponse, response: nil, error: nil)

        //  events
        let a = PageViewEvent(eventName: "a", attributes: [:], userID: "1", timestamp: date, eventDuration: 0.05)
        let b = PageViewEvent(eventName: "b", attributes: [:], userID: "1", timestamp: date, eventDuration: 0.05)
        p.addToQueue(a)
        p.addToQueue(b)
        dispatchQueue.async { self.writeWait1.fulfill() }

        let pandataEvents = p.batchOfEvents(2)?.map { $0.apiEvent(tokenResponse) } ?? []

        // mock the send events req
        let batchReq = PostPandataEventsRequest(token: tokenResponse, events: pandataEvents)
        let batchUrlReq = try! batchReq.urlRequest(relativeTo: api.baseURL, accessToken: api.accessToken, actAsUserID: nil)
        api.mocks[batchUrlReq] = ("\"ok\"".data(using: .utf8), nil, nil)
        print(api.mocks.keys)

        wait(for: [writeWait1], timeout: 0.5)
        XCTAssertEqual(p.queueCount, 2)

        requestManager.sendEvents { (error) in
            XCTAssertNil(error)
            self.expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(p.queueCount, 0)
    }

    func testCleanup() {
        let keychain = GeneralPurposeKeychain(serviceName: Pandata.tokenKeychainService)
        let added = keychain.setData("foobar".data(using: .utf8)!, for: Pandata.tokenKeychainKey)
        XCTAssertTrue(added)

        if let data = keychain.data(for: Pandata.tokenKeychainKey), let value = String(data: data, encoding: .utf8) {
            XCTAssertNotNil(value)
        } else {
            XCTFail()
        }

        requestManager.cleanup()

        let data = keychain.data(for: Pandata.tokenKeychainKey)
        XCTAssertNil(data)
    }
}
