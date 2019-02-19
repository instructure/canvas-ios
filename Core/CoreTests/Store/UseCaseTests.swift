//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import XCTest
import CoreData
@testable import Core

class UseCaseTests: CoreTestCase {
    class TestUseCase: UseCase {
        typealias Model = Course
        typealias Response = APICourse

        let cacheKey = "test-cache-key"

        func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
            completionHandler(nil, nil, nil)
        }
        func write(response: APICourse?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
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
    }

    func testScope() {
        let useCase = TestUseCase()
        XCTAssertEqual(useCase.scope, Scope.all(orderBy: "id"))
    }

    func testGetNext() {
        let useCase = TestUseCase()
        let urlResponse = URLResponse(url: URL(fileURLWithPath: "/"), mimeType: nil, expectedContentLength: 2, textEncodingName: nil)
        XCTAssertNil(useCase.getNext(from: urlResponse))
    }

    func testGetNextUseCase() {
        class ParentUseCase: TestUseCase {
            let expectation = XCTestExpectation(description: "write was called")
            override func write(response: APICourse?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
                expectation.fulfill()
            }
        }
        let parent = ParentUseCase()
        let useCase = GetNextUseCase(parent: parent, request: GetNextRequest(path: "/"))
        XCTAssertEqual(useCase.ttl, 0)
        XCTAssertEqual(useCase.scope, parent.scope)
        try! useCase.write(response: nil, urlResponse: nil, to: databaseClient)
        wait(for: [parent.expectation], timeout: 0.1)
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

        let expectation = XCTestExpectation(description: "fetch completion block")
        var response: APICourse?
        useCase.fetch(environment: environment, force: false) { r, _, _ in
            response = r
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertNil(response)
    }

    func testFetchForced() {
        class UseCase: TestUseCase {
            let makeRequestExpectation = XCTestExpectation(description: "makeRequest was called")
            let writeExpectation = XCTestExpectation(description: "write was called")
            var course: APICourse?

            override func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
                completionHandler(nil, nil, nil)
                makeRequestExpectation.fulfill()
            }

            override func write(response: APICourse?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
                writeExpectation.fulfill()
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

        wait(for: [useCase.makeRequestExpectation, useCase.writeExpectation, fetchExpectation], timeout: 0.1)
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

    func testFetchWriteError() {
        class UseCase: TestUseCase {
            override func write(response: APICourse?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
                throw NSError.instructureError("write failed")
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
}

class CollectionUseCaseTests: CoreTestCase {
    class TestCollectionUseCase: CollectionUseCase {
        typealias Model = Course

        var request: GetCoursesRequest {
            return GetCoursesRequest(includeUnpublished: false)
        }

        let scope = Scope.all(orderBy: "name")
        let cacheKey = "test-collection-use-case"
        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        }
    }

    func testMakeRequestDeletes() {
        Course.make()
        XCTAssertEqual((databaseClient.fetch() as [Course]).count, 1)

        let useCase = TestCollectionUseCase()
        let expectation = XCTestExpectation(description: "make request callback")
        useCase.makeRequest(environment: environment) { _, _, _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        databaseClient.refresh()
        XCTAssertEqual((databaseClient.fetch() as [Course]).count, 0)
    }

    func testMakeRequestError() {
        let useCase = TestCollectionUseCase()
        let error = NSError.instructureError("request error")
        api.mock(useCase.request, value: nil, response: nil, error: error)
        let expectation = XCTestExpectation(description: "make request callback")
        var result: Error?
        useCase.makeRequest(environment: environment) { _, _, e in
            result = e
            expectation.fulfill()
        }
        XCTAssertNotNil(result)
    }
}

class APIUseCaseTests: CoreTestCase {
    class TestAPIUseCase: APIUseCase {
        var request: GetCoursesRequest {
            return GetCoursesRequest(includeUnpublished: true)
        }
        let scope = Scope.all(orderBy: "name")
        let cacheKey = "api-use-case"
        func write(response: [APICourse]?, urlResponse: URLResponse?, to client: PersistenceClient) throws {
        }
    }

    func testGetNext() {
        let useCase = TestAPIUseCase()
        let prev = "https://cgnuonline-eniversity.edu/api/v1/date"
        let curr = "https://cgnuonline-eniversity.edu/api/v1/date?page=2"
        let next = "https://cgnuonline-eniversity.edu/api/v1/date?page=3"
        let headers = [
            "Link": "<\(curr)>; rel=\"current\",<>;, <\(prev)>; rel=\"prev\", <\(next)>; rel=\"next\"; count=1",
        ]
        let response = HTTPURLResponse(url: URL(string: curr)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
        XCTAssertEqual(useCase.getNext(from: response)?.path, next)
    }
}
