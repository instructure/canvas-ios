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

final class LearningLibraryBookMarkUseCaseTests: HorizonTestCase {

    private var testee: LearningLibraryBookMarkUseCase!
    private let testId = "item-123"
    private let testItemId = "course-456"

    override func setUpWithError() throws {
        testee = LearningLibraryBookMarkUseCase(id: testId, itemID: testItemId)
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertNil(testee.cacheKey)
    }

    func testRequest() {
        XCTAssertEqual(testee.request.variables.input.collectionItemId, testId)
    }

    func testScope() {
        let predicate = testee.scope.predicate
        XCTAssertNotNil(predicate)
    }

    func testMakeRequestSuccess() {
        testee = LearningLibraryBookMarkUseCase(
            journey: DomainServiceMock(result: .success(api)),
            id: testId,
            itemID: testItemId
        )
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
        api.mock(
            testee.request,
            value: LearningLibraryBookMarkResponse(
                data: .init(
                    toggleCollectionItemBookmark: .init(isBookmarked: true)
                )
            )
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.data.toggleCollectionItemBookmark.isBookmarked, true)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = LearningLibraryBookMarkUseCase(
            journey: domainService,
            id: testId,
            itemID: testItemId
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

    func testWriteUpdatesBookmarkToTrue() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(item?.isBookmarked, true)

        let response = LearningLibraryBookMarkResponse(
            data: .init(
                toggleCollectionItemBookmark: .init(isBookmarked: false)
            )
        )

        testee = LearningLibraryBookMarkUseCase(id: "item-1", itemID: "course-123")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(updatedItem?.isBookmarked, false)
    }

    func testWriteUpdatesBookmarkToFalse() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem2, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-456"
        )
        XCTAssertEqual(item?.isBookmarked, true)

        let response = LearningLibraryBookMarkResponse(
            data: .init(
                toggleCollectionItemBookmark: .init(isBookmarked: true)
            )
        )

        testee = LearningLibraryBookMarkUseCase(id: "item-2", itemID: "course-456")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-456"
        )
        XCTAssertEqual(updatedItem?.isBookmarked, true)
    }

    func testWriteWithNilResponse() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        let originalBookmarkState = item?.isBookmarked

        testee = LearningLibraryBookMarkUseCase(id: "item-1", itemID: "course-123")
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(updatedItem?.isBookmarked, originalBookmarkState)
    }
}
