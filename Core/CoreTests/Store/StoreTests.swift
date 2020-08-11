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

import CoreData
import Foundation
import XCTest
@testable import Core

class StoreTests: CoreTestCase {
    struct TestUseCase: UseCase {
        typealias Model = Course

        let courses: [APICourse]?
        let requestError: Error?
        let urlResponse: URLResponse?

        init(courses: [APICourse]? = nil, requestError: Error? = nil, urlResponse: URLResponse? = nil) {
            self.courses = courses
            self.requestError = requestError
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

        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
            guard let response = response else {
                return
            }
            for item in response {
                let predicate = NSPredicate(format: "%K == %@", #keyPath(Course.id), item.id.value)
                let course: Course = client.fetch(predicate).first ?? client.insert()
                course.name = item.name
                course.id = item.id.value
                course.isFavorite = item.is_favorite ?? false
            }
        }

        func getNext(from urlResponse: URLResponse) -> GetNextRequest<[APICourse]>? {
            return GetCoursesRequest().getNext(from: urlResponse)
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
        let course = APICourse.make(id: "1")
        let useCase = TestUseCase(courses: [course])
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots.first!
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        let loaded = snapshots.last!
        XCTAssertEqual(loaded.count, 1)
        XCTAssertFalse(loaded.pending)
        XCTAssertEqual(loaded.objects.first?.id, "1")
        XCTAssertNil(loaded.error)

        let ttls: [TTL] = databaseClient.fetch()
        XCTAssertEqual(ttls.count, 1)
    }

    func testSubscribeWithForceRefresh() {
        let course = APICourse.make(id: "1")
        let useCase = TestUseCase(courses: [course])
        eventsExpectation.expectedFulfillmentCount = 3
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh(force: true)

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots.first!
        XCTAssertTrue(loading.pending)

        let loaded = snapshots.last!
        XCTAssertFalse(loaded.pending)
    }

    func testSubscribeWithCache() {
        let course = APICourse.make(id: "1")
        let useCase = TestUseCase(courses: [course])
        let multipleEvents = XCTestExpectation(description: "too many store events")
        multipleEvents.isInverted = true

        store = environment.subscribe(useCase) {
            self.storeUpdated()
            if self.snapshots.count > 1 {
                multipleEvents.fulfill()
            }
        }

        Course.make(from: .make(id: "1"))
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
        eventsExpectation.expectedFulfillmentCount = 2
        store = environment.subscribe(useCase, storeUpdated)
        store.refresh()

        wait(for: [eventsExpectation], timeout: 1.0)

        let loading = snapshots.first!
        XCTAssertEqual(loading.count, 0)
        XCTAssertTrue(loading.pending)
        XCTAssertNil(loading.error)

        let error = snapshots.last!
        XCTAssertEqual(error.count, 0)
        XCTAssertFalse(error.pending)
        XCTAssertEqual(error.error?.localizedDescription, "network error")

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
        secondPage.expectedFulfillmentCount = 6

        let course1 = APICourse.make(id: "1")
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
        let course2 = APICourse.make(id: "2")
        api.mock(useCase.getNext(from: response)!, value: [course2], response: nil, error: nil)
        store.getNextPage()
        wait(for: [secondPage], timeout: 1.0)
        XCTAssertEqual(store.count, 2)
    }

    func testSequence() {
        Course.make(from: .make(id: "1"))
        Course.make(from: .make(id: "2"))
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        let ids = store.map { $0.id }
        XCTAssertEqual(ids.count, 2)
        XCTAssert(ids.contains("1"))
        XCTAssert(ids.contains("2"))
    }

    func testSubscriptInt() {
        let one = Course.make(from: .make(id: "1", name: "A"))
        let two = Course.make(from: .make(id: "2", name: "B"))
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(one, store[0])
        XCTAssertEqual(two, store[1])
    }

    func testSubscriptIntObjectNotPresent() {
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }
        XCTAssertNil(store[1])
    }

    func testSubscriptSectionNotPresent() {
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }
        XCTAssertNil(store[IndexPath(row: 1, section: 1)])
    }

    func testFirst() {
        let one = Course.make(from: .make(id: "1", name: "A"))
        Course.make(from: .make(id: "2", name: "B"))
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(store.first, one)
    }

    func testLast() {
        Course.make(from: .make(id: "1", name: "A"))
        let two = Course.make(from: .make(id: "2", name: "B"))
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(store.last, two)
    }

    func testAll() {
        let one = Course.make(from: .make(id: "1", name: "A"))
        let two = Course.make(from: .make(id: "2", name: "B"))
        let useCase = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let store = Store(env: environment, useCase: useCase) { }

        XCTAssertEqual(store.all, [one, two])
    }

    func testChanges() {
        let use = TestUseCase(courses: nil, requestError: nil, urlResponse: nil)
        let notified = expectation(description: "notified")
        let store = Store(env: environment, useCase: use) { notified.fulfill() }
        let request = NSFetchRequest<Course>(entityName: String(describing: Course.self))
        request.predicate = use.scope.predicate
        request.sortDescriptors = use.scope.order
        let frc: NSFetchedResultsController<Course> = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: databaseClient,
            sectionNameKeyPath: use.scope.sectionNameKeyPath,
            cacheName: nil
        )
        try? frc.performFetch()
        let frc2 = frc as! NSFetchedResultsController<NSFetchRequestResult>
        store.changes = [.insertSection(0)]
        store.controllerDidChangeContent(frc2)
        wait(for: [notified], timeout: 1)
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
        let page1 = [APICourse.make(id: "1")]
        let page2 = [APICourse.make(id: "2")]
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
        let page1 = [APICourse.make(id: "1")]
        let page2 = [APICourse.make(id: "2")]
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

    func testDeletedObjects() {
        let store = environment.subscribe(TestUseCase()) {}
        let course = Course.make()
        XCTAssertNotNil(store[0])
        databaseClient.delete(course)
        XCTAssertEqual(store.numberOfSections, 1)
        XCTAssertEqual(store.numberOfObjects(inSection: 0), 1)
        XCTAssertNil(store[0])
    }
}
