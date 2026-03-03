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

final class GetCollectionItemBookmarkedUseCaseTests: HorizonTestCase {

    private var testee: GetCollectionItemBookmarkedUseCase!

    override func setUpWithError() throws {
        testee = GetCollectionItemBookmarkedUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "Learning-Library-Items")
    }

    func testRequest() {
        XCTAssertTrue(testee.request.variables.bookmarkedOnly)
        XCTAssertFalse(testee.request.variables.completedOnly)
        XCTAssertEqual(testee.request.variables.limit, 100)
    }

    func testMakeRequestSuccess() {
        testee = GetCollectionItemBookmarkedUseCase(journey: DomainServiceMock(result: .success(api)))
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
        api.mock(
            testee.request,
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: LearningLibraryItemStubs.response,
                        pageInfo: .init(
                            nextCursor: nil,
                            previousCursor: nil,
                            hasNextPage: false,
                            hasPreviousPage: false
                        )
                    )
                )
            )
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertEqual(response?.count, 2)
            XCTAssertEqual(response?.first?.id, "item-1")
            XCTAssertEqual(response?.first?.isBookmarked, true)
            XCTAssertEqual(response?.last?.id, "item-2")
            XCTAssertEqual(response?.last?.isBookmarked, true)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = GetCollectionItemBookmarkedUseCase(journey: domainService)
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token"),
            error: DomainJWTService.Issue.unableToGetToken
        )
        api.mock(
            testee.request,
            value: GetHLearningLibraryItemResponse(data: nil),
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
        let response = LearningLibraryItemStubs.response

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 2)
        let item1 = stored.first { $0.id == "item-1" }
        let item2 = stored.first { $0.id == "item-2" }

        XCTAssertEqual(item1?.id, "item-1")
        XCTAssertEqual(item1?.courseID, "course-123")
        XCTAssertEqual(item1?.name, "Introduction to Swift")
        XCTAssertEqual(item1?.isBookmarked, true)
        XCTAssertEqual(item1?.completionPercentage, 0.65)
        XCTAssertEqual(item1?.displayOrder, NSNumber(value: 1))

        XCTAssertEqual(item2?.id, "item-2")
        XCTAssertEqual(item2?.courseID, "course-456")
        XCTAssertEqual(item2?.name, "Advanced SwiftUI")
        XCTAssertEqual(item2?.isBookmarked, true)
        XCTAssertEqual(item2?.completionPercentage, 0.30)
        XCTAssertEqual(item2?.displayOrder, NSNumber(value: 2))
    }

    func testWriteResponseWithNilResponse() {
        testee.write(response: nil, urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }

    func testWriteResponseWithEmptyArray() {
        testee.write(response: [], urlResponse: nil, to: databaseClient)
        let stored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()

        XCTAssertEqual(stored.count, 0)
    }

    func testScope() {
        testee.write(response: LearningLibraryItemStubs.response, urlResponse: nil, to: databaseClient)

        let fetched: [CDHLearningLibraryCollectionItem] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(fetched.count, 2)
        XCTAssertTrue(fetched.allSatisfy { $0.isBookmarked })
        XCTAssertEqual(fetched.first?.displayOrder, NSNumber(value: 1))
        XCTAssertEqual(fetched.last?.displayOrder, NSNumber(value: 2))
    }

    func testScopeFiltersNonBookmarkedItems() {
        let unbookmarkedItemJSON = """
        {
            "id": "item-3",
            "libraryId": "library-3",
            "itemType": "COURSE",
            "displayOrder": 3,
            "isBookmarked": false,
            "completionPercentage": 0.50,
            "isEnrolledInCanvas": false,
            "createdAt": "2026-01-20T00:00:00Z",
            "updatedAt": "2026-02-20T00:00:00Z",
            "canvasCourse": {
                "courseId": "course-123",
                "courseName": "Introduction to Swift"
            }
        }
        """
        let unbookmarkedItem = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: unbookmarkedItemJSON.data(using: .utf8)!)
        let response = LearningLibraryItemStubs.response + [unbookmarkedItem]

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let allStored: [CDHLearningLibraryCollectionItem] = databaseClient.fetch()
        let bookmarkedOnly: [CDHLearningLibraryCollectionItem] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(allStored.count, 3)
        XCTAssertEqual(bookmarkedOnly.count, 2)
        XCTAssertTrue(bookmarkedOnly.allSatisfy { $0.isBookmarked })
    }

    func testScopeOrdersByDisplayOrder() {
        let item3JSON = """
        {
            "id": "item-3",
            "libraryId": "library-3",
            "itemType": "COURSE",
            "displayOrder": 0,
            "isBookmarked": true,
            "completionPercentage": 0.90,
            "isEnrolledInCanvas": true,
            "createdAt": "2026-01-05T00:00:00Z",
            "updatedAt": "2026-02-05T00:00:00Z",
            "canvasCourse": {
                "courseId": "course-123",
                "courseName": "Introduction to Swift"
            }
        }
        """
        let item3 = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: item3JSON.data(using: .utf8)!)
        let response = LearningLibraryItemStubs.response + [item3]

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let fetched: [CDHLearningLibraryCollectionItem] = databaseClient.fetch(scope: testee.scope)

        XCTAssertEqual(fetched.count, 3)
        XCTAssertEqual(fetched[0].displayOrder, NSNumber(value: 0))
        XCTAssertEqual(fetched[1].displayOrder, NSNumber(value: 1))
        XCTAssertEqual(fetched[2].displayOrder, NSNumber(value: 2))
    }
}
