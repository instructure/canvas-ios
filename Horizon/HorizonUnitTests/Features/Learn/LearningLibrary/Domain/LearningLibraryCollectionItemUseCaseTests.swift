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

@testable import Horizon
@testable import Core
import XCTest
import Combine

final class LearningLibraryCollectionItemUseCaseTests: HorizonTestCase {

    private var testee: LearningLibraryCollectionItemUseCase!
    private let testCollectionId = "collection-123"

    override func setUpWithError() throws {
        testee = LearningLibraryCollectionItemUseCase(id: testCollectionId)
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "Learning-Library-Collection-Item-\(testCollectionId)")
    }

    func testRequest() {
        XCTAssertEqual(testee.request.variables.id, testCollectionId)
    }

    func testMakeRequestSuccess() {
        testee = LearningLibraryCollectionItemUseCase(
            id: testCollectionId,
            journey: DomainServiceMock(result: .success(api))
        )
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
        api.mock(
            testee.request,
            value: GetHLearningLibraryCollectionItemResponse(
                data: .init(
                    enrolledLearningLibraryCollection: .init(
                        id: testCollectionId,
                        name: "Test Collection",
                        publicName: "Public Collection",
                        description: "Description",
                        createdAt: "2026-01-01T00:00:00Z",
                        updatedAt: "2026-02-01T00:00:00Z",
                        items: LearningLibraryItemStubs.response
                    )
                )
            )
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.data?.enrolledLearningLibraryCollection?.items?.count, 2)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = LearningLibraryCollectionItemUseCase(
            id: testCollectionId,
            journey: domainService
        )
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token"),
            error: DomainJWTService.Issue.unableToGetToken
        )

        testee.makeRequest(environment: environment) { response, _, error in
            expectation.fulfill()
            XCTAssertNil(response)
            XCTAssertEqual(error?.localizedDescription, DomainJWTService.Issue.unableToGetToken.localizedDescription)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testWriteResponseSavesItems() {
        let response = GetHLearningLibraryCollectionItemResponse(
            data: .init(
                enrolledLearningLibraryCollection: .init(
                    id: testCollectionId,
                    name: "Test Collection",
                    publicName: "Public Collection",
                    description: "Description",
                    createdAt: "2026-01-01T00:00:00Z",
                    updatedAt: "2026-02-01T00:00:00Z",
                    items: LearningLibraryItemStubs.response
                )
            )
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 2)
        let item1 = stored.first { $0.id == "item-1" }
        let item2 = stored.first { $0.id == "item-2" }

        XCTAssertNotNil(item1)
        XCTAssertNotNil(item2)
        XCTAssertEqual(item1?.name, "Introduction to Swift")
        XCTAssertEqual(item2?.name, "Advanced SwiftUI")
    }

    func testWriteResponseWithNilData() {
        let response = GetHLearningLibraryCollectionItemResponse(data: nil)

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }

    func testWriteResponseWithNilItems() {
        let response = GetHLearningLibraryCollectionItemResponse(
            data: .init(
                enrolledLearningLibraryCollection: .init(
                    id: testCollectionId,
                    name: "Test Collection",
                    publicName: "Public Collection",
                    description: nil,
                    createdAt: "2026-01-01T00:00:00Z",
                    updatedAt: "2026-02-01T00:00:00Z",
                    items: nil
                )
            )
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }
}
