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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class ModuleStoreTests: CoreTestCase {
    var onChange: (() -> Void)?
    var onError: ((Error) -> Void)?

    override func setUp() {
        super.setUp()
    }

    func testRefreshCached() {
        let courseID = "1"
        Module.make(forCourse: courseID)
        let store = ModuleStore(courseID: courseID)
        store.refresh()
        XCTAssertEqual(store.count, 1)
    }

    func testRefreshAPI() {
        let expectation = XCTestExpectation(description: "on change")
        onChange = expectation.fulfill
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make()])
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        store.refresh(force: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
    }

    func testRefreshAPIPaginated() {
        let expectation = XCTestExpectation(description: "first page")
        expectation.expectedFulfillmentCount = 3
        onChange = expectation.fulfill
        let link = "https://canvas.instructure.com/courses/1/modules?page=2"
        let response = HTTPURLResponse(next: link)
        let request = GetModulesRequest(courseID: "1", include: [.items, .content_details])
        api.mock(request, value: [.make(id: "1", position: 1, items: [])], response: response)
        let task = api.mock(request.getNext(from: response)!, value: [.make(id: "2", position: 2, items: [])])
        task.paused = true
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        store.refresh(force: true)
        XCTAssertTrue(store.isLoading)
        task.paused = false
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 2)
        XCTAssertEqual(store[0].id, "1")
        XCTAssertEqual(store[1].id, "2")
        XCTAssertFalse(store.isLoading)
    }

    func testLoadingItemsForModule() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "1", items: nil)])
        let task = api.mock(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details]), value: [.make()])
        task.paused = true
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        var expectation = XCTestExpectation(description: "loading items")
        onChange = expectation.fulfill
        store.refresh(force: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(store.isLoadingItemsForModule("1"))
        expectation = XCTestExpectation(description: "finished loading")
        onChange = expectation.fulfill
        task.paused = false
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store[0].items.count, 1)
        XCTAssertFalse(store.isLoadingItemsForModule("1"))
    }

    func testRefreshWhenItemsAreNilPaginated() {
        let expectation = XCTestExpectation(description: "on change")
        expectation.expectedFulfillmentCount = 3
        onChange = expectation.fulfill
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "1", items: nil)])
        let link = "https://canvas.instructure.com/api/v1/courses/1/modules/1/items?page=2"
        let response = HTTPURLResponse(next: link)
        let request = GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details])
        api.mock(request, value: [.make(id: "1")], response: response)
        api.mock(request.getNext(from: response)!, value: [.make(id: "2")])
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        store.refresh(force: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store[0].items.count, 2)
    }

    func testForceRefreshDeletesCache() {
        Module.make(from: .make(id: "1"), forCourse: "1")
        let expectation = XCTestExpectation(description: "on change")
        onChange = expectation.fulfill
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(id: "2")])
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        store.refresh(force: true)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store[0].id, "2")
    }

    func testRefreshForcesIfTTLExpired() {
        let expectation = XCTestExpectation(description: "on change")
        onChange = expectation.fulfill
        let store = ModuleStore(courseID: "1")
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make()])
        TTL.make(key: store.cacheKey, lastRefresh: Clock.now.addDays(-1))
        store.delegate = self
        store.refresh(force: false)
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(store.count, 1)
    }

    func testRefreshDoesNotForceIfTTLValid() {
        let now = Date()
        Clock.mockNow(now)
        let expectation = XCTestExpectation(description: "on change")
        expectation.isInverted = true
        onChange = expectation.fulfill
        let store = ModuleStore(courseID: "1")
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make()])
        TTL.make(key: store.cacheKey, lastRefresh: now)
        store.delegate = self
        store.refresh(force: false)
        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(store.count, 0)
    }

    func testRefreshRenewsTTL() {
        api.mock(GetModulesRequest(courseID: "1", include: [.items, .content_details]), value: [.make(items: [])])
        let expectation = XCTestExpectation(description: "on change")
        expectation.expectedFulfillmentCount = 3
        onChange = expectation.fulfill
        let store = ModuleStore(courseID: "1")
        store.delegate = self
        XCTAssertTrue(store.shouldRefresh)
        store.refresh()
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse(store.shouldRefresh)
    }

    func testSectionForModule() {
        Module.make(forCourse: "1")
        let store = ModuleStore(courseID: "1")
        store.refresh()
        XCTAssertEqual(store.sectionForModule("1"), 0)
        XCTAssertNil(store.sectionForModule("2"))
    }
}

extension ModuleStoreTests: ModuleStoreDelegate {
    func moduleStoreDidEncounterError(_ error: Error) {
        onError?(error)
    }

    func moduleStoreDidChange(_ moduleStore: ModuleStore) {
        onChange?()
    }
}
