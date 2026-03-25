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

final class LearningLibraryCollectionUseCaseTests: HorizonTestCase {

    private var testee: LearningLibraryCollectionUseCase!

    override func setUpWithError() throws {
        testee = LearningLibraryCollectionUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "Learning-Library-Collection")
    }

    func testRequest() {
        XCTAssertEqual(testee.request.variables.itemLimitPerCollection, 4)
    }

    func testScope() {
        XCTAssertEqual(testee.scope, .all)
    }

    func testMakeRequestSuccess() {
        testee = LearningLibraryCollectionUseCase(journey: DomainServiceMock(result: .success(api)))
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )

        let collectionJSON1 = """
        {
            "id": "collection-1",
            "name": "Featured Collection",
            "publicName": "Featured",
            "description": "A featured collection",
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-02-01T00:00:00Z",
            "totalItemCount": 2,
            "items": []
        }
        """
        let collectionJSON2 = """
        {
            "id": "collection-2",
            "name": "Trending Collection",
            "publicName": "Trending",
            "description": "Trending courses",
            "createdAt": "2026-01-15T00:00:00Z",
            "updatedAt": "2026-02-15T00:00:00Z",
            "totalItemCount": 3,
            "items": []
        }
        """

        let collection1 = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON1.data(using: .utf8)!)
        let collection2 = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON2.data(using: .utf8)!)

        api.mock(
            testee.request,
            value: GetHLearningLibraryCollectionResponse(
                data: .init(
                    enrolledLearningLibraryCollections: .init(
                        collections: [collection1, collection2]
                    )
                )
            )
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.data.enrolledLearningLibraryCollections.collections.count, 2)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = LearningLibraryCollectionUseCase(journey: domainService)
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

    func testWriteResponseSavesCollections() {
        let collectionJSON1 = """
        {
            "id": "collection-1",
            "name": "Featured Collection",
            "publicName": "Featured",
            "description": "A featured collection",
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-02-01T00:00:00Z",
            "totalItemCount": 2,
            "items": []
        }
        """
        let collectionJSON2 = """
        {
            "id": "collection-2",
            "name": "Trending Collection",
            "publicName": "Trending",
            "description": null,
            "createdAt": "2026-01-15T00:00:00Z",
            "updatedAt": "2026-02-15T00:00:00Z",
            "totalItemCount": 3,
            "items": []
        }
        """

        let collection1 = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON1.data(using: .utf8)!)
        let collection2 = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON2.data(using: .utf8)!)

        let response = GetHLearningLibraryCollectionResponse(
            data: .init(
                enrolledLearningLibraryCollections: .init(
                    collections: [collection1, collection2]
                )
            )
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollection] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 2)
        let col1 = stored.first { $0.id == "collection-1" }
        let col2 = stored.first { $0.id == "collection-2" }

        XCTAssertEqual(col1?.name, "Featured Collection")
        XCTAssertEqual(col1?.totalItemCount, "2")
        XCTAssertEqual(col2?.name, "Trending Collection")
        XCTAssertEqual(col2?.totalItemCount, "3")
    }

    func testWriteResponseWithNilResponse() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollection] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }

    func testWriteResponseWithEmptyCollections() {
        let response = GetHLearningLibraryCollectionResponse(
            data: .init(
                enrolledLearningLibraryCollections: .init(
                    collections: []
                )
            )
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollection] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }
}
