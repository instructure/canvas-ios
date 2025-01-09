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

    func testErrorHandling() {
        let useCase = TestUseCase(courses: nil, requestError: NSError.instructureError("TestError"))
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .getEntities()
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                        XCTAssertTrue(Thread.isMainThread)
                    }
                },
                receiveValue: { _ in }
            )

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
            .getEntities(ignoreCache: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.map { $0.id }, ["0"])
                    expectation.fulfill()
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testObjectsAreReturnedFromNetwork() {
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .getEntities(ignoreCache: true)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.map { $0.id }, ["1"])
                    expectation.fulfill()
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    // MARK: - Direct database calling

    func testObjectsAreReturnedFromDatabase() {
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
            .getEntitiesFromDatabase()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.map { $0.id }, ["0"])
                    expectation.fulfill()
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    // MARK: - Force fetch

    func testIgnoreCache() {
        Course.save(.make(id: "0"), in: databaseClient)
        try! databaseClient.save()
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Date()
        try! databaseClient.save()

        let expectation1 = expectation(description: "Publisher sends value")
        let expectation2 = expectation(description: "Publisher sends value")
        expectation2.expectedFulfillmentCount = 2
        var fulfillmentCount = 0
        let subscription = testee
            .getEntities(ignoreCache: false, keepObservingDatabaseChanges: true)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    fulfillmentCount += 1
                    if fulfillmentCount == 1 {
                        XCTAssertEqual(courses.map { $0.id }, ["0"])
                        expectation1.fulfill()
                    }

                    if fulfillmentCount == 2 {
                        XCTAssertEqual(courses.map { $0.id }, ["1", "0"])
                        expectation2.fulfill()
                    }
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        wait(for: [expectation1], timeout: 0.1)
        let subscription2 = testee.forceRefresh(loadAllPages: true)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    expectation2.fulfill()
                }
            )

        wait(for: [expectation2], timeout: 0.1)
        subscription2.cancel()
        subscription.cancel()
    }

    // MARK: - Database changes

    func testNewlyAddedObjectsArePublished() {
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .getEntities(keepObservingDatabaseChanges: true)
            .dropFirst() // Skip the initial empty data as we wait for the new item to be added
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.map { $0.id }, ["3rdpartyinsert"])
                    expectation.fulfill()
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        drainMainQueue()
        Course.save(.make(id: "3rdpartyinsert"), in: databaseClient)

        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testDatabaseChangesArePublished() {
        let course = Course.save(.make(id: "1"), in: databaseClient)
        try! databaseClient.save()
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let expectation = expectation(description: "Publisher sends value")
        let subscription = testee
            .getEntities(ignoreCache: false, keepObservingDatabaseChanges: true)
            .dropFirst() // Skip initial data as we wait for the "name" field update
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.map { $0.id }, ["1"])
                    XCTAssertEqual(courses.first?.name, "updatedName")
                    expectation.fulfill()
                    XCTAssertTrue(Thread.isMainThread)
                }
            )

        drainMainQueue()
        course.name = "updatedName"
        waitForExpectations(timeout: 1)
        subscription.cancel()
    }

    func testDatabaseDeletionsArePublished() {
        let course = Course.save(.make(id: "1"), in: databaseClient)
        try! databaseClient.save()
        let store = createStore(useCase: TestUseCase())

        let expectation1 = expectation(description: "Publisher sends value")
        let subscription1 = store.getEntities(ignoreCache: false, keepObservingDatabaseChanges: true)
            .dropFirst() // Skip initial data as we wait for the delete update
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.count, 0)
                    expectation1.fulfill()
                }
            )

        drainMainQueue()
        databaseClient.delete(course)
        waitForExpectations(timeout: 0.1)
        subscription1.cancel()
    }

    // MARK: - LoadAllPages

    func testLoadAllPages() {
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1"
        ]
        let urlResponse = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        let page1 = [APICourse.make(id: "1")]
        let page2 = [APICourse.make(id: "2")]
        let useCase = TestUseCase(courses: page1, urlResponse: urlResponse)
        api.mock(useCase.getNext(from: urlResponse)!, value: page2, response: nil, error: nil)
        let expectation1 = XCTestExpectation(description: "exhausted")
        let store = createStore(useCase: useCase)

        let subscription1 = store.getEntities(ignoreCache: true, loadAllPages: false)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.count, 1)
                    expectation1.fulfill()
                }
            )

        wait(for: [expectation1], timeout: 0.1)
        subscription1.cancel()

        let expectation2 = XCTestExpectation(description: "Publisher sends value")
        let subscription2 = store.getEntities(ignoreCache: true, loadAllPages: true)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.count, 2)
                    expectation2.fulfill()
                }
            )

        wait(for: [expectation2], timeout: 0.1)
        subscription2.cancel()
    }

    // MARK: - Offline

    func test_OfflineModeIsEnabled_ObjectsAreReturnedFromDatabase() {
        // Given
        Course.make(from: .make(id: "0"))
        injectOfflineFeatureFlag(isEnabled: true)

        // When
        let expectation = expectation(description: "Refresh callback called")
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        let subscription = store.getEntities()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.count, 1)
                    let ids = courses.map { $0.id }
                    XCTAssertEqual(ids.count, 1)
                    XCTAssert(ids.contains("0"))
                    XCTAssert(!ids.contains("1"))
                    expectation.fulfill()
                }
            )

        // Then
        waitForExpectations(timeout: 0.3)
        subscription.cancel()
    }

    func test_OfflineModeIsNotEnabled_ObjectsAreReturnedFromNetwork() {
        // Given
        Course.make(from: .make(id: "0"))
        injectOfflineFeatureFlag(isEnabled: false)

        // When
        let expectation = expectation(description: "Refresh callback called")
        expectation.expectedFulfillmentCount = 1
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        let subscription = store.getEntities()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { courses in
                    XCTAssertEqual(courses.count, 2)
                    let ids = courses.map { $0.id }
                    XCTAssertEqual(ids.count, 2)
                    XCTAssert(ids.contains("0"))
                    XCTAssert(ids.contains("1"))
                    expectation.fulfill()
                }
            )

        // Then
        waitForExpectations(timeout: 0.3)
        subscription.cancel()
    }

    // MARK: - Subscription cancellation

    func testSubscriptionCancellation() {
        let store = createStore(useCase: TestUseCase(courses: [.make(id: "1")]))
        let interactor = TestInteractor(store: store, keepObservingDatabaseChanges: false)
        let expectation1 = expectation(description: "Publisher sends value")
        let expectation2 = expectation(description: "Publisher wont send value")
        expectation2.isInverted = true
        var expectationCount = 0

        let subscription = interactor.$entities
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
            offlineModeInteractor: createOfflineModeInteractor(),
            context: environment.database.viewContext,
            useCase: useCase
        )
    }

    private func createOfflineModeInteractor() -> OfflineModeInteractor {
        let monitor = NWPathMonitorWrapper(start: { _ in () }, cancel: {})
        let availabilityService = NetworkAvailabilityServiceLive(monitor: monitor)
        let result = OfflineModeInteractorLive(availabilityService: availabilityService,
                                               isOfflineModeEnabledForApp: true)
        drainMainQueue()
        return result
    }

    private func injectOfflineFeatureFlag(isEnabled: Bool) {
        let scope: Scope = .where(#keyPath(FeatureFlag.name),
                                  equals: EnvironmentFeatureFlags.mobile_offline_mode.rawValue,
                                  sortDescriptors: [])
        let flag: FeatureFlag = databaseClient.fetch(scope: scope).first ?? databaseClient.insert()
        flag.name = EnvironmentFeatureFlags.mobile_offline_mode.rawValue
        flag.isEnvironmentFlag = true
        flag.enabled = isEnabled
        flag.context = .currentUser
    }
}

extension ReactiveStoreTests {
    class TestInteractor {
        // MARK: - Output

        @Published public var entities: [Course] = []

        // MARK: - Depenencies

        private let store: ReactiveStore<TestUseCase>

        // MARK: - Private properties

        private var subscriptions = Set<AnyCancellable>()

        init(store: ReactiveStore<TestUseCase>, keepObservingDatabaseChanges: Bool) {
            self.store = store

            self.store.getEntities(keepObservingDatabaseChanges: keepObservingDatabaseChanges)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] in
                        self?.entities = $0
                    }
                )
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
