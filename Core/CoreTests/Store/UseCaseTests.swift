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
import CoreData
import Combine
@testable import Core

class UseCaseTests: CoreTestCase {
    class TestUseCase: UseCase {
        typealias Model = Course
        typealias Response = APICourse

        let cacheKey: String? = "test-cache-key"

        func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
            completionHandler(nil, nil, nil)
        }
        func write(response: APICourse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        }
        func reset(context: NSManagedObjectContext) {
        }
    }

    func testTTL() {
        let useCase = TestUseCase()
        XCTAssertEqual(useCase.ttl, 60 * 60 * 2)

        let now = Date()
        Clock.mockNow(now)
        useCase.updateTTL(in: databaseClient)
        XCTAssertFalse(useCase.hasExpired(in: databaseClient))

        Clock.mockNow(now.addingTimeInterval(useCase.ttl))
        XCTAssertFalse(useCase.hasExpired(in: databaseClient))

        Clock.mockNow(now.addingTimeInterval(useCase.ttl + 1))
        XCTAssertTrue(useCase.hasExpired(in: databaseClient))

        Clock.reset()
    }

    func testScope() {
        let useCase = TestUseCase()
        XCTAssertEqual(useCase.scope, Scope.all(orderBy: "objectID"))
    }

    func testGetNext() {
        let useCase = TestUseCase()
        let urlResponse = URLResponse(url: URL(string: "/")!, mimeType: nil, expectedContentLength: 2, textEncodingName: nil)
        XCTAssertNil(useCase.getNext(from: urlResponse))
    }

    func testGetNextUseCase() {
        class ParentUseCase: TestUseCase {
            let expectation = XCTestExpectation(description: "write was called")
            override func write(response: APICourse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
                expectation.fulfill()
            }
        }
        let parent = ParentUseCase()
        let useCase = GetNextUseCase(parent: parent, request: GetNextRequest(path: "/"))
        XCTAssertEqual(useCase.ttl, 0)
        XCTAssertEqual(useCase.scope, parent.scope)
        useCase.write(response: nil, urlResponse: nil, to: databaseClient)
        wait(for: [parent.expectation], timeout: 1)
    }

    func testFetchCached() {
        class UseCase: TestUseCase {
            override func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
                completionHandler(APICourse.make(), nil, nil)
            }
        }
        let useCase = UseCase()

        let now = Date()
        Clock.mockNow(now)
        useCase.updateTTL(in: databaseClient)
        try! databaseClient.save()

        let expectation = XCTestExpectation(description: "fetch completion block")
        var response: APICourse?
        useCase.fetch(environment: environment, force: false) { r, _, _ in
            response = r
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertNil(response)
    }

    func testFetchForced() {
        class UseCase: TestUseCase {
            let makeRequestExpectation = XCTestExpectation(description: "makeRequest was called")
            let writeExpectation = XCTestExpectation(description: "write was called")
            let resetExpectation = XCTestExpectation(description: "reset was called")
            var course: APICourse?

            override func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
                completionHandler(nil, nil, nil)
                makeRequestExpectation.fulfill()
            }

            override func write(response: APICourse?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
                writeExpectation.fulfill()
            }

            override func reset(context: NSManagedObjectContext) {
                resetExpectation.fulfill()
            }
        }
        let useCase = UseCase()
        let now = Date()
        Clock.mockNow(now)
        useCase.updateTTL(in: databaseClient)

        let fetchExpectation = XCTestExpectation(description: "fetch callback")
        useCase.fetch(environment: environment, force: true) { _, _, _ in
            fetchExpectation.fulfill()
        }

        wait(for: [useCase.makeRequestExpectation, useCase.writeExpectation, fetchExpectation, useCase.resetExpectation], timeout: 1)
    }

    func testFetchMakeRequestError() {
        class UseCase: TestUseCase {
            override func makeRequest(environment: AppEnvironment, completionHandler: @escaping UseCaseTests.TestUseCase.RequestCallback) {
                completionHandler(nil, nil, NSError.instructureError("request failed"))
            }
        }
        var error: Error?
        let expectation = XCTestExpectation(description: "fetch callback")
        let useCase = UseCase()
        useCase.fetch(environment: environment, force: true) { _, _, e in
            error = e
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.1)
        XCTAssertNotNil(error)
    }

    func testFutureFailureCallbacksOnMain() {
        class UseCase: TestUseCase {
            override func makeRequest(environment: AppEnvironment, completionHandler: @escaping UseCaseTests.TestUseCase.RequestCallback) {
                completionHandler(nil, nil, NSError.instructureError("request failed"))
            }
        }
        let useCase = UseCase()
        let expectation = expectation(description: "Fetch fails.")
        var subscription: AnyCancellable?

        DispatchQueue.global().async {
            subscription = useCase.fetchWithFuture()
                .sink { completion in
                    if case .failure = completion {
                        XCTAssertEqual(Thread.isMainThread, true)
                        expectation.fulfill()
                    }
                } receiveValue: { _ in }
        }
        waitForExpectations(timeout: 0.1)
        subscription?.cancel()
    }

    func testFailureCallbacksOnMain() {
        class UseCase: TestUseCase {
            override func makeRequest(environment _: AppEnvironment, completionHandler: @escaping UseCaseTests.TestUseCase.RequestCallback) {
                completionHandler(nil, nil, NSError.instructureError("request failed"))
            }
        }
        let useCase = UseCase()
        let expectation = expectation(description: "Fetch fails.")

        DispatchQueue.global().async {
            useCase.fetch { _, _, error in
                if error != nil {
                    XCTAssertEqual(Thread.isMainThread, true)
                    expectation.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 0.1)
    }
}

class CollectionUseCaseTests: CoreTestCase {
    class TestCollectionUseCase: CollectionUseCase {
        typealias Model = Course

        var request: GetCoursesRequest {
            return GetCoursesRequest()
        }

        let scope = Scope.all(orderBy: "name")
        let cacheKey: String? = "test-collection-use-case"
        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) throws {
        }
    }

    func testFetchDeletes() {
        Course.make()
        XCTAssertEqual((databaseClient.fetch() as [Course]).count, 1)

        let useCase = TestCollectionUseCase()
        let expectation = XCTestExpectation(description: "make request callback")
        useCase.fetch(environment: environment) { _, _, _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        databaseClient.refresh()
        XCTAssertEqual((databaseClient.fetch() as [Course]).count, 0)
    }
}

class DeleteUseCaseTests: CoreTestCase {
    class TestDeleteUseCase: DeleteUseCase {
        typealias Model = File

        var request: DeleteFileRequest {
            return DeleteFileRequest(fileID: "1")
        }

        let scope = Scope.all(orderBy: "name")
        let cacheKey: String? = nil
    }

    func testFetchDeletes() {
        let useCase = TestDeleteUseCase()

        File.make()
        XCTAssertEqual((databaseClient.fetch(scope: useCase.scope) as [File]).count, 1)

        let expectation = XCTestExpectation(description: "make request callback")
        useCase.fetch(environment: environment) { _, _, _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        databaseClient.refresh()
        XCTAssertEqual((databaseClient.fetch(scope: useCase.scope) as [File]).count, 0)
    }
}

class APIUseCaseTests: CoreTestCase {
    class TestAPIUseCase: APIUseCase {
        var request: GetCoursesRequest {
            return GetCoursesRequest()
        }
        let scope = Scope.all(orderBy: "name")
        let cacheKey: String? = "api-use-case"
        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        }
    }

    func testGetNext() {
        let useCase = TestAPIUseCase()
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1"
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        XCTAssertEqual(useCase.getNext(from: response)?.path, next)
    }
}

class WriteableModelTests: CoreTestCase {
    struct TestUseCase: UseCase {
        typealias Model = Group

        func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIGroup?, URLResponse?, Error?) -> Void) {
        }

        let scope = Scope.all(orderBy: "name")
        let cacheKey: String? = "writeable"
    }

    func testWrite() {
        let useCase = TestUseCase()
        useCase.write(response: APIGroup.make(id: "1"), urlResponse: nil, to: databaseClient)
        let group: Group = databaseClient.fetch().first!
        XCTAssertEqual(group.id, "1")
    }
}
