//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
@testable import Core
import CoreData
import XCTest
import TestsFoundation

final class AsyncStoreTests: CoreTestCase {
    var store: AsyncStore<TestUseCase>!

    override func tearDown() {
        super.tearDown()
        store = nil
    }

    @MainActor
    func testErrorHandling() async {
        let useCase = TestUseCase(courses: nil, requestError: NSError.instructureError("TestError"))
        let testee = createStore(useCase: useCase)

        do {
            _ = try await testee.getEntities()
            XCTFail("Expected to throw error")
        } catch {
            XCTAssertTrue(Thread.isMainThread)
        }
    }

    // MARK: Publishing from Network and Cache

    func testObjectsAreReturnedFromCache() async throws {
        Course.save(.make(id: "0"), in: databaseClient)
        try databaseClient.save()
        let useCase = TestUseCase()
        let testee = createStore(useCase: useCase)

        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Date()
        try databaseClient.save()

        let courses = try await testee.getEntities(ignoreCache: false)
        XCTAssertEqual(courses.map { $0.id }, ["0"])
    }

    func testObjectsAreReturnedFromNetwork() async throws {
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let courses = try await testee.getEntities(ignoreCache: true)
        XCTAssertEqual(courses.map { $0.id }, ["1"])
    }

    // MARK: - Direct database calling

    func testObjectsAreReturnedFromDatabase() async throws {
        Course.save(.make(id: "0"), in: databaseClient)
        try! databaseClient.save()
        let useCase = TestUseCase()
        let testee = createStore(useCase: useCase)

        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Date()
        try databaseClient.save()

        let courses = try await testee.getEntitiesFromDatabase()
        XCTAssertEqual(courses.map { $0.id }, ["0"])
    }

    // MARK: - Force fetch

    func testIgnoreCache() async throws {
        Course.save(.make(id: "0"), in: databaseClient)
        try databaseClient.save()
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testee = createStore(useCase: useCase)

        let cache: TTL = databaseClient.insert()
        cache.key = useCase.cacheKey ?? ""
        cache.lastRefresh = Date()
        try databaseClient.save()

        let expectation1 = expectation(description: "First iteration")
        let expectation2 = expectation(description: "Second iteration")
        var iterationCount = 0
        let task = Task {
            let stream = try await testee.streamEntities(ignoreCache: false)

            for try await courses in stream {
                iterationCount += 1
                if iterationCount == 1 {
                    XCTAssertEqual(courses.map { $0.id }, ["0"])
                    expectation1.fulfill()
                } else if iterationCount == 2 {
                    XCTAssertEqual(courses.map { $0.id }, ["1", "0"])
                    expectation2.fulfill()
                }
            }
        }
        await fulfillment(of: [expectation1], timeout: 1)

        await testee.forceRefresh(loadAllPages: true)
        await fulfillment(of: [expectation2], timeout: 1)
        task.cancel()
    }

    // MARK: - Database changes

    func testNewlyAddedObjectsArePublished() async {
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let initialExpectation = expectation(description: "Initial iteration")
        let newItemExpectation = expectation(description: "Iteration with new item")
        var iterationCount = 0

        let task = Task {
            let stream = try await testee.streamEntities()

            for try await courses in stream {
                iterationCount += 1

                if iterationCount == 1 {
                    initialExpectation.fulfill()
                } else {
                    XCTAssertEqual(courses.map { $0.id }, ["3rdpartyinsert"])
                    newItemExpectation.fulfill()
                }
            }
        }
        await fulfillment(of: [initialExpectation], timeout: 1)

        Course.save(.make(id: "3rdpartyinsert"), in: databaseClient)

        await fulfillment(of: [newItemExpectation], timeout: 1)
        task.cancel()
    }

    func testDatabaseChangesArePublished() async throws {
        let course = Course.save(.make(id: "1"), in: databaseClient)
        try databaseClient.save()
        let useCase = TestUseCase(courses: [])
        let testee = createStore(useCase: useCase)

        let initialExpectation = expectation(description: "Initial iteration")
        let updatedItemExpectation = expectation(description: "Iteration with updated item")
        var iterationCount = 0
        let task = Task {
            let stream = try await testee.streamEntities(ignoreCache: false)

            for try await courses in stream {
                iterationCount += 1

                if iterationCount == 1 {
                    initialExpectation.fulfill()
                } else {
                    XCTAssertEqual(courses.map { $0.id }, ["1"])
                    XCTAssertEqual(courses.first?.name, "updatedName")
                    updatedItemExpectation.fulfill()
                }
            }
        }
        await fulfillment(of: [initialExpectation], timeout: 1)

        course.name = "updatedName"
        try await Task.sleep(for: .seconds(1))
        await fulfillment(of: [updatedItemExpectation], timeout: 1)
        task.cancel()
    }

    func testDatabaseDeletionsArePublished() async throws {
        let course = Course.save(.make(id: "1"), in: databaseClient)
        try databaseClient.save()
        let store = createStore(useCase: TestUseCase())

        let initialExpectation = expectation(description: "Initial iteration")
        let deletedItemExpectation = expectation(description: "Iteration with deleted item")
        var iterationCount = 0
        let task = Task {
            let stream = try await store.streamEntities()

            for try await courses in stream {
                iterationCount += 1

                if iterationCount == 1 {
                    initialExpectation.fulfill()
                } else {
                    XCTAssertEqual(courses.count, 0)
                    deletedItemExpectation.fulfill()
                }
            }
        }
        await fulfillment(of: [initialExpectation], timeout: 1)

        databaseClient.delete(course)
        await fulfillment(of: [deletedItemExpectation], timeout: 1)
        task.cancel()
    }

    // MARK: - LoadAllPages

    func testLoadAllPages() async throws {
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
        let store = createStore(useCase: useCase)

        var courses = try await store.getEntities(ignoreCache: true, loadAllPages: false)
        XCTAssertEqual(courses.count, 1)

        courses = try await store.getEntities(ignoreCache: true, loadAllPages: true)
        XCTAssertEqual(courses.count, 2)
    }

    // MARK: - Offline

    func test_OfflineModeIsEnabled_ObjectsAreReturnedFromDatabase() async throws {
        // Given
        Course.make(from: .make(id: "0"))
        injectOfflineFeatureFlag(isEnabled: true)

        // When
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        let courses = try await store.getEntities()
        XCTAssertEqual(courses.count, 1)
        let ids = courses.map { $0.id }
        XCTAssertEqual(ids.count, 1)
        XCTAssert(ids.contains("0"))
        XCTAssert(!ids.contains("1"))
    }

    func test_OfflineModeIsNotEnabled_ObjectsAreReturnedFromNetwork() async throws {
        // Given
        Course.make(from: .make(id: "0"))
        injectOfflineFeatureFlag(isEnabled: false)

        // When
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let store = createStore(useCase: useCase)

        let courses = try await store.getEntities()
        XCTAssertEqual(courses.count, 2)
        let ids = courses.map { $0.id }
        XCTAssertEqual(ids.count, 2)
        XCTAssert(ids.contains("0"))
        XCTAssert(ids.contains("1"))
    }


    // MARK: - Custom App Environment

    func testCustomEnvironmentIsUsed() async throws {
        let useCase = TestUseCase(courses: [.make(id: "1")])
        let testEnvironment = TestEnvironment()
        store = AsyncStore(useCase: useCase, environment: testEnvironment)

        _ = try await store.getEntities(ignoreCache: true)

        XCTAssertTrue(useCase.receivedEnvironmentInMakeRequest === testEnvironment)
        XCTAssertTrue(useCase.receivedEnvironmentInMakeRequest !== AppEnvironment.shared)
    }

    // MARK: - Private methods

    private func createStore<U: UseCase>(useCase: U) -> AsyncStore<U> {
        AsyncStore(
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

extension AsyncStoreTests {
    final class TestUseCase: UseCase {
        typealias Model = Course

        let courses: [APICourse]?
        let requestError: Error?
        let urlResponse: URLResponse?

        private(set) var receivedEnvironmentInMakeRequest: AppEnvironment?

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
            receivedEnvironmentInMakeRequest = environment
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
