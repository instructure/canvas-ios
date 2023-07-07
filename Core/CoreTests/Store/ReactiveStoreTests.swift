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

import Combine
@testable import Core
import CoreData
import Foundation
import XCTest

class ReactiveStoreTests: CoreTestCase {
    var store: ReactiveStore<TestUseCase>!

    override func tearDown() {
        super.tearDown()
        store = nil
    }

    // MARK: State

    func testLoadingState() {
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .sink { state in
                XCTAssertEqual(state, .loading)
                expectation.fulfill()
                XCTAssertTrue(Thread.isMainThread)
            }

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testDataState() {
        let useCase = TestUseCase(courses: [.make()])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .dropFirst()
            .sink { state in
                if case .data = state {
                    expectation.fulfill()
                }
                XCTAssertTrue(Thread.isMainThread)
            }

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testErrorState() {
        let useCase = TestUseCase(courses: nil, requestError: NSError.instructureError("TestError"))
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .sink { state in
                if case .error = state {
                    expectation.fulfill()
                }
                XCTAssertTrue(Thread.isMainThread)
            }

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    // MARK: Publishing from Network and Cache

    func testObjectsAreReturnedFromCache() {
        Course.save(.make(id: "0"), in: databaseClient)
        try! databaseClient.save()
        let useCase = TestUseCase()
        let testee = createStore(useCase: useCase)

        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Date()
        try! databaseClient.save()

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .dropFirst()
            .sink { state in
                switch state {
                case let .data(courses):
                    XCTAssertEqual(courses.map { $0.id }, ["0"])
                default:
                    break
                }
                expectation.fulfill()
                XCTAssertTrue(Thread.isMainThread)
            }

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testObjectsAreReturnedFromNetwork() {
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .dropFirst()
            .sink { state in
                switch state {
                case let .data(courses):
                    XCTAssertEqual(courses.map { $0.id }, ["1"])
                default:
                    break
                }
                expectation.fulfill()
                XCTAssertTrue(Thread.isMainThread)
            }

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    // MARK: - Database changes

    func testNewlyAddedObjectsArePublished() {
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities()
            .dropFirst(2) // drop .loading and initialy .data[]
            .sink { state in
                switch state {
                case let .data(courses):
                    XCTAssertEqual(courses.map { $0.id }, ["3rdpartyinsert"])
                default:
                    break
                }
                expectation.fulfill()
                XCTAssertTrue(Thread.isMainThread)
            }

        drainMainQueue()
        Course.save(.make(id: "3rdpartyinsert"), in: databaseClient)

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testDatabaseChangesArePublished() {
        let course = Course.save(.make(id: "1"), in: databaseClient)
        try! databaseClient.save()
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .observeEntities(forceFetch: false)
            .dropFirst()
            .sink { state in
                switch state {
                case let .data(courses):
                    XCTAssertEqual(courses.map { $0.id }, ["1"])
                    XCTAssertEqual(courses.first?.name, "updatedName")
                default:
                    break
                }
                expectation.fulfill()
                XCTAssertTrue(Thread.isMainThread)
            }

        course.name = "updatedName"
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testDatabaseDeletionsArePublished() {
        let store = createStore(useCase: TestUseCase())
        let course = Course.make()

        let expectation1 = expectation(description: "Publisher sends value")
        let subscription1 = store.observeEntities(forceFetch: false)
            .sink { state in
                if case let .data(courses) = state {
                    XCTAssertEqual(courses.count, 1)
                    expectation1.fulfill()
                }
            }

        wait(for: [expectation1], timeout: 0.1)
        subscription1.cancel()

        let expectation2 = expectation(description: "Publisher sends value")
        let subscription2 = store.observeEntities(forceFetch: false)
            .dropFirst() // Drop previously saved data
            .sink { state in
                if case let .data(courses) = state {
                    XCTAssertEqual(courses.count, 0)
                    expectation2.fulfill()
                }
            }

        databaseClient.delete(course)
        wait(for: [expectation2], timeout: 0.1)
        subscription2.cancel()
    }

    // MARK: - LoadAllPages

    func testLoadAllPages() {
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
        let expectation1 = XCTestExpectation(description: "exhausted")
        let store = createStore(useCase: useCase)

        let subscription1 = store.observeEntities(forceFetch: true)
            .sink { state in
                if case let .data(courses) = state {
                    if courses.count == 1 {
                        expectation1.fulfill()
                    }
                }
            }

        wait(for: [expectation1], timeout: 0.1)
        subscription1.cancel()

        let expectation2 = XCTestExpectation(description: "Publisher sends value")
        let subscription2 = store.observeEntities(forceFetch: true, loadAllPages: true)
            .dropFirst()
            .sink { state in
                if case let .data(courses) = state {
                    XCTAssertEqual(courses.count, 2)
                    expectation2.fulfill()
                }
            }

        wait(for: [expectation2], timeout: 0.1)
        subscription2.cancel()
    }

    // MARK: - Offline

    func test_OfflineModeIsEnabled_ObserveEntitiesCalled_ObjectsAreReturnedFromDatabase() {
        // Given
        let course = Course.make(from: .make(id: "0"))
        ExperimentalFeature.offlineMode.isEnabled = true

        // When
        let expectation = expectation(description: "Refresh callback called")
        expectation.expectedFulfillmentCount = 2
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        var states = [ReactiveStore<TestUseCase>.State]()
        let subscription = store.observeEntities(forceFetch: false)
            .sink { state in
                expectation.fulfill()
                states.append(state)
            }

        // Then
        waitForExpectations(timeout: 0.3)
        let ids = states.map {
            switch $0 {
            case let .data(course):
                return course
            default:
                return []
            }
        }.flatMap { $0.map { $0.id } }

        XCTAssertEqual(states.count, 2)
        XCTAssertEqual(states[0], .loading)
        XCTAssertEqual(states[1], .data([course]))
        XCTAssertEqual(ids.count, 1)
        XCTAssert(ids.contains("0"))
        XCTAssert(!ids.contains("1"))
        subscription.cancel()
    }

    func test_OfflineModeIsEnabled_GetEntitiesCalled_ObjectsAreReturnedFromDatabase() {
        // Given
        Course.make(from: .make(id: "0"))
        ExperimentalFeature.offlineMode.isEnabled = true

        // When
        let expectation = expectation(description: "Refresh callback called")
        expectation.expectedFulfillmentCount = 1
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        var courseList = [Course]()
        let subscription = store.getEntities()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    expectation.fulfill()
                    courseList.append(contentsOf: courses)
                }
            )

        // Then
        waitForExpectations(timeout: 0.3)
        let ids = courseList.map { $0.id }

        XCTAssertEqual(courseList.count, 1)
        XCTAssertEqual(ids.count, 1)
        XCTAssert(ids.contains("0"))
        XCTAssert(!ids.contains("1"))
        subscription.cancel()
    }

    func test_OfflineModeIsNotEnabled_ObserveEntitiesCalled_ObjectsAreReturnedFromNetwork() {
        // Given
        Course.make(from: .make(id: "0"))
        ExperimentalFeature.offlineMode.isEnabled = false

        // When
        let expectation = expectation(description: "Refresh callback called")
        expectation.expectedFulfillmentCount = 2
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        var states = [ReactiveStore<TestUseCase>.State]()
        let subscription = store.observeEntities(forceFetch: false)
            .sink { state in
                expectation.fulfill()
                states.append(state)
            }

        // Then
        waitForExpectations(timeout: 0.3)
        let ids = states.map {
            switch $0 {
            case let .data(course):
                return course
            default:
                return []
            }
        }.flatMap { $0.map { $0.id } }

        XCTAssertEqual(states.count, 2)
        XCTAssertEqual(states[0], .loading)
        XCTAssertEqual(ids.count, 2)
        XCTAssert(ids.contains("0"))
        XCTAssert(ids.contains("1"))
        subscription.cancel()
    }

    func test_OfflineModeIsNotEnabled_GetEntitiesCalled_ObjectsAreReturnedFromNetwork() {
        // Given
        Course.make(from: .make(id: "0"))
        ExperimentalFeature.offlineMode.isEnabled = false

        // When
        let expectation = expectation(description: "Refresh callback called")
        expectation.expectedFulfillmentCount = 1
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        var courseList = [Course]()
        let subscription = store.getEntities()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    expectation.fulfill()
                    courseList.append(contentsOf: courses)
                }
            )

        // Then
        waitForExpectations(timeout: 0.3)
        let ids = courseList.map { $0.id }

        XCTAssertEqual(courseList.count, 2)
        XCTAssertEqual(ids.count, 2)
        XCTAssert(ids.contains("0"))
        XCTAssert(ids.contains("1"))
        subscription.cancel()
    }

    // MARK: - Subscription cancellation

    func testSubscriptionCancellation() {
        let store = createStore(useCase: TestUseCase(courses: [.make(id: "1")]))
        let interactor = TestInteractor(store: store)
        let expectation1 = expectation(description: "Publisher sends value")
        let expectation2 = expectation(description: "Publisher wont send value")
        expectation2.isInverted = true
        var expectationCount = 0

        let subscription = interactor.state
            .dropFirst()
            .sink(receiveValue: { _ in
                if expectationCount == 0 {
                    expectation1.fulfill()
                    expectationCount += 1
                } else {
                    expectation2.fulfill()
                }
            })

        wait(for: [expectation1], timeout: 0.1)
        subscription.cancel()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            Course.save(.make(id: "2"), in: self.databaseClient)
        }

        wait(for: [expectation2], timeout: 0.3)
        subscription.cancel()
    }

    private func createStore<U: UseCase>(useCase: U) -> ReactiveStore<U> {
        ReactiveStore(
            env: environment,
            offlineModeInteractor: createOfflineModeInteractor(),
            context: environment.database.viewContext,
            useCase: useCase
        )
    }

    private func createOfflineModeInteractor() -> OfflineModeInteractor {
        let monitor = NWPathMonitorWrapper(start: { _ in () }, cancel: {})
        let availabilityService = NetworkAvailabilityServiceLive(monitor: monitor)
        return OfflineModeInteractorLive(availabilityService: availabilityService)
    }
}

extension ReactiveStoreTests {
    struct TestInteractor {
        // MARK: - Output

        public let state = CurrentValueSubject<ReactiveStore<TestUseCase>.State, Never>(.loading)

        // MARK: - Depenencies

        private let store: ReactiveStore<TestUseCase>

        // MARK: - Private properties

        private var subscriptions = Set<AnyCancellable>()

        init(store: ReactiveStore<TestUseCase>) {
            self.store = store

            self.store.observeEntities()
                .subscribe(state)
                .store(in: &subscriptions)
        }
    }

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

        func makeRequest(environment _: AppEnvironment, completionHandler: @escaping ([APICourse]?, URLResponse?, Error?) -> Void) {
            completionHandler(courses, urlResponse, requestError)
        }

        func write(response: [APICourse]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
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
}
