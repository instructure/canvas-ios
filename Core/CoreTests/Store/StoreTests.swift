//
// Copyright (C) 2019-present Instructure, Inc.
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

import CoreData
import Foundation
import XCTest
@testable import Core

class StoreTests: CoreTestCase {
    struct TestUseCase: UseCase {
        typealias Model = Course

        let courses: [APICourse]?
        let requestError: Error?
        let writeError: Error?
        let urlResponse: URLResponse?

        init(courses: [APICourse]? = nil, requestError: Error? = nil, writeError: Error? = nil, urlResponse: URLResponse? = nil) {
            self.courses = courses
            self.requestError = requestError
            self.writeError = writeError
            self.urlResponse = urlResponse
        }

        var scope: Scope {
            return .all(orderBy: #keyPath(Course.name))
        }

        var cacheKey: String? {
            return "test-use-case"
        }

        func makeRequest(environment: AppEnvironment, completionHandler: @escaping ([APICourse]?, URLResponse?, Error?) -> Void) {
            completionHandler(courses, urlResponse, requestError)
        }

        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
            if let error = writeError {
                throw error
            }
            guard let response = response else {
                return
            }
            for item in response {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), item.id)
                let course: Course = client.fetch(predicate).first ?? client.insert()
                course.name = item.name
                course.id = item.id
                course.isFavorite = item.is_favorite ?? false
            }
        }

        func getNext(from urlResponse: URLResponse) -> GetNextRequest<[APICourse]>? {
            return GetCoursesRequest(includeUnpublished: false).getNext(from: urlResponse)
        }
    }

    // Copy store since it is mutable
    struct StoreSnapshot {
        let pending: Bool
        let error: Error?
        let count: Int
        let objects: [TestUseCase.Model]

        init(store: Store<TestUseCase>) {
            self.pending = store.pending
            self.error = store.error
            self.count = store.count

            var objects: [TestUseCase.Model] = []
            for section in 0..<store.numberOfSections {
                for row in 0..<store.numberOfObjects(inSection: section) {
                    if let object = store[IndexPath(row: row, section: section)] {
                        objects.append(object)
                    }
                }
            }
            self.objects = objects
        }
    }

    var store: Store<TestUseCase>!
    var snapshots: [StoreSnapshot] = []
    let eventsExpectation = XCTestExpectation(description: "store events")

    func storeUpdated() {
        let snapshot = StoreSnapshot(store: self.store)
        self.snapshots.append(snapshot)
        self.eventsExpectation.fulfill()
    }

    func testSubscribeWithoutCache() {
        let course = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course])
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots[0]
        let notLoading = snapshots[1]
        let loaded = snapshots[2]

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertFalse(notLoading.pending)
        XCTAssertNil(notLoading.error)

        // loaded
        XCTAssertEqual(loaded.count, 1)
        XCTAssertFalse(loaded.pending)
        XCTAssertEqual(loaded.objects.first?.id, "1")
        XCTAssertNil(loaded.error)

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 1)
    }

    func testSubscribeWithForceRefresh() {
        let course = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course])
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh(force: true)

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots[0]
        let notLoading = snapshots[1]
        let loaded = snapshots[2]

        // loading
        XCTAssertTrue(loading.pending)

        // not loading
        XCTAssertFalse(notLoading.pending)

        // loaded
        XCTAssertFalse(loaded.pending)
    }

    func testSubscribeWithCache() {
        let course = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course])
        let multipleEvents = XCTestExpectation(description: "too many store events")
        multipleEvents.isInverted = true

        store = environment.subscribe(useCase) {
            self.storeUpdated()
            if self.snapshots.count > 1 {
                multipleEvents.fulfill()
            }
        }

        Course.make(["id": "1"])
        let now = Date()
        Clock.mockNow(now)
        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Clock.now
        try! databaseClient.save()

        wait(for: [eventsExpectation], timeout: 1.0)
        wait(for: [multipleEvents], timeout: 1.0)
        XCTAssertEqual(snapshots.count, 1)

        let cached = snapshots[0]
        XCTAssertEqual(cached.objects.first?.id, "1")
        XCTAssertFalse(cached.pending)
        XCTAssertNil(cached.error)
    }

    func testSubscribeWithNetworkError() {
        let requestError = NSError.instructureError("network error")
        let useCase = TestUseCase(requestError: requestError)
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots[0]
        let notLoading = snapshots[1]
        let error = snapshots[2]

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertEqual(notLoading.count, 0)
        XCTAssertFalse(notLoading.pending)

        // error
        XCTAssertEqual(error.count, 0)
        XCTAssertFalse(error.pending)
        XCTAssertEqual(error.error?.localizedDescription, "network error")

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 0)
    }

    func testSubscribeWithWriteError() {
        let writeError = NSError.instructureError("write error")
        let useCase = TestUseCase(writeError: writeError)
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots[0]
        let notLoading = snapshots[1]
        let error = snapshots[2]

        // loading
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        // not loading
        XCTAssertEqual(notLoading.count, 0)
        XCTAssertFalse(notLoading.pending)

        // error
        XCTAssertEqual(error.count, 0)
        XCTAssertFalse(error.pending)
        XCTAssertEqual(error.error?.localizedDescription, "write error")

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 0)
    }

    func testGetNextPage() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let secondPage = XCTestExpectation(description: "second page of courses")
        secondPage.expectedFulfillmentCount = 4

        let course1 = APICourse.make(["id": "1"])
        let useCase = TestUseCase(courses: [course1], urlResponse: response)
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase) {
            self.storeUpdated()
            secondPage.fulfill()
        }
        store.refresh()

        // first page
        wait(for: [eventsExpectation], timeout: 1.0)

        XCTAssertEqual(store.count, 1)
        let course2 = APICourse.make(["id": "2"])
        api.mock(useCase.getNext(from: response)!, value: [course2], response: nil, error: nil)
        store.getNextPage()
        wait(for: [secondPage], timeout: 1.0)
        XCTAssertEqual(store.count, 2)
    }

    func testSequence() {
        Course.make(["id": "1"])
        Course.make(["id": "2"])
        let useCase = TestUseCase(courses: nil, requestError: nil, writeError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        let ids = store.map { $0.id }
        XCTAssertEqual(ids.count, 2)
        XCTAssert(ids.contains("1"))
        XCTAssert(ids.contains("2"))
    }

    func testSubscriptInt() {
        let one = Course.make(["id": "1", "name": "A"])
        let two = Course.make(["id": "2", "name": "B"])
        let useCase = TestUseCase(courses: nil, requestError: nil, writeError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(one, store[0])
        XCTAssertEqual(two, store[1])
    }

    func testFirst() {
        let one = Course.make(["id": "1", "name": "A"])
        Course.make(["id": "2", "name": "B"])
        let useCase = TestUseCase(courses: nil, requestError: nil, writeError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(store.first, one)
    }

    func testLast() {
        Course.make(["id": "1", "name": "A"])
        let two = Course.make(["id": "2", "name": "B"])
        let useCase = TestUseCase(courses: nil, requestError: nil, writeError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(store.last, two)
    }

    func testChanges() {
        let use = TestUseCase(courses: nil, requestError: nil, writeError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: use) { }
        let frc: NSFetchedResultsController<Course> = environment.database.fetchedResultsController(
            predicate: use.scope.predicate,
            sortDescriptors: use.scope.order,
            sectionNameKeyPath: use.scope.sectionNameKeyPath
        )
        try? frc.performFetch()
        let frc2 = frc as! NSFetchedResultsController<NSFetchRequestResult>
        store.changes = [.insertSection(0)]
        store.controllerWillChangeContent(frc2)
        XCTAssertEqual(store.changes, [])
        store.controller(frc2, didChange: frc.sections![0], atSectionIndex: 0, for: .insert)
        store.controller(frc2, didChange: frc.sections![0], atSectionIndex: 0, for: .delete)
        store.controller(frc2, didChange: [], at: nil, for: .insert, newIndexPath: IndexPath(row: 1, section: 2))
        store.controller(frc2, didChange: [], at: IndexPath(row: 2, section: 3), for: .update, newIndexPath: nil)
        store.controller(frc2, didChange: [], at: IndexPath(row: 3, section: 4), for: .delete, newIndexPath: nil)
        store.controller(frc2, didChange: [], at: IndexPath(row: 4, section: 5), for: .move, newIndexPath: IndexPath(row: 5, section: 6))
        XCTAssertEqual(store.changes, [
            .insertSection(0),
            .deleteSection(0),
            .insertRow(IndexPath(row: 1, section: 2)),
            .updateRow(IndexPath(row: 2, section: 3)),
            .deleteRow(IndexPath(row: 3, section: 4)),
            .deleteRow(IndexPath(row: 4, section: 5)),
            .insertRow(IndexPath(row: 5, section: 6)),
        ])
    }

    func testExhaustWhileKeepsGoing() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let urlResponse = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let page1 = [APICourse.make(["id": "1"])]
        let page2 = [APICourse.make(["id": "2"])]
        let useCase = TestUseCase(courses: page1, urlResponse: urlResponse)
        api.mock(useCase.getNext(from: urlResponse)!, value: page2, response: nil, error: nil)
        let expectation = XCTestExpectation(description: "exhausted")
        store = environment.subscribe(useCase) {
            if self.store.count == 2 {
                expectation.fulfill()
            }
        }

        store.exhaust(while: { _ in return true })
        wait(for: [expectation], timeout: 0.5)
    }

    func testExhaustWhileStops() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let urlResponse = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let page1 = [APICourse.make(["id": "1"])]
        let page2 = [APICourse.make(["id": "2"])]
        let useCase = TestUseCase(courses: page1, urlResponse: urlResponse)
        api.mock(useCase.getNext(from: urlResponse)!, value: page2, response: nil, error: nil)
        let expectation = XCTestExpectation(description: "exhausted")
        expectation.isInverted = true
        store = environment.subscribe(useCase) {
            if self.store.count == 2 {
                expectation.fulfill()
            }
        }

        store.exhaust(while: { _ in return false })
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(store.count, 1)
    }
}
