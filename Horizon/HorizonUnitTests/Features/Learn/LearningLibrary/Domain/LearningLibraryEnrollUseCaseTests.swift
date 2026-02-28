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

final class LearningLibraryEnrollUseCaseTests: HorizonTestCase {

    private var testee: LearningLibraryEnrollUseCase!
    private let testId = "item-123"
    private let testItemId = "course-456"

    override func setUpWithError() throws {
        testee = LearningLibraryEnrollUseCase(id: testId, itemID: testItemId)
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
        testee = LearningLibraryEnrollUseCase(
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
            value: LearningLibraryEnrollCollectionItemResponse(
                data: .init(
                    enrollLearnerInCollectionItem: .init(
                        wasAlreadyEnrolled: false,
                        item: LearningLibraryItemStubs.bookmarkedItem1
                    )
                )
            )
        )

        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            XCTAssertNotNil(response)
            XCTAssertEqual(response?.data.enrollLearnerInCollectionItem.wasAlreadyEnrolled, false)
            XCTAssertEqual(response?.data.enrollLearnerInCollectionItem.item.canvasEnrollmentId, "enrollment-123")
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        let domainService = DomainServiceMock(result: .failure(DomainJWTService.Issue.unableToGetToken))
        testee = LearningLibraryEnrollUseCase(
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

    func testWriteUpdatesEnrollment() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(item?.isEnrolledInCanvas, true)
        XCTAssertEqual(item?.canvasEnrollmentId, "enrollment-123")

        let response = LearningLibraryEnrollCollectionItemResponse(
            data: .init(
                enrollLearnerInCollectionItem: .init(
                    wasAlreadyEnrolled: false,
                    item: LearningLibraryItemStubs.bookmarkedItem1
                )
            )
        )

        testee = LearningLibraryEnrollUseCase(id: "item-1", itemID: "course-123")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(updatedItem?.isEnrolledInCanvas, true)
        XCTAssertEqual(updatedItem?.canvasEnrollmentId, "enrollment-123")
    }

    func testWriteWithNewEnrollmentId() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem2, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-456"
        )
        XCTAssertNil(item?.canvasEnrollmentId)

        let enrolledItemJSON = """
        {
            "id": "item-2",
            "libraryId": "library-2",
            "itemType": "COURSE",
            "displayOrder": 2,
            "isBookmarked": true,
            "completionPercentage": 0.30,
            "isEnrolledInCanvas": true,
            "createdAt": "2026-01-15T00:00:00Z",
            "updatedAt": "2026-02-15T00:00:00Z",
            "canvasCourse": {
                "courseId": "course-456",
                "courseName": "Advanced SwiftUI"
            },
            "programId": "program-456",
            "programCourseId": "program-course-789",
            "canvasEnrollmentId": "new-enrollment-999"
        }
        """
        let enrolledItem = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: enrolledItemJSON.data(using: .utf8)!)

        let response = LearningLibraryEnrollCollectionItemResponse(
            data: .init(
                enrollLearnerInCollectionItem: .init(
                    wasAlreadyEnrolled: false,
                    item: enrolledItem
                )
            )
        )

        testee = LearningLibraryEnrollUseCase(id: "item-2", itemID: "course-456")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-456"
        )
        XCTAssertEqual(updatedItem?.isEnrolledInCanvas, true)
        XCTAssertEqual(updatedItem?.canvasEnrollmentId, "new-enrollment-999")
    }

    func testWriteWithNilEnrollmentId() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        let originalEnrollmentId = item?.canvasEnrollmentId

        let noEnrollmentItemJSON = """
        {
            "id": "item-1",
            "libraryId": "library-1",
            "itemType": "COURSE"
        }
        """
        let noEnrollmentItem = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: noEnrollmentItemJSON.data(using: .utf8)!)

        let response = LearningLibraryEnrollCollectionItemResponse(
            data: .init(
                enrollLearnerInCollectionItem: .init(
                    wasAlreadyEnrolled: true,
                    item: noEnrollmentItem
                )
            )
        )

        testee = LearningLibraryEnrollUseCase(id: "item-1", itemID: "course-123")
        testee.write(response: response, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(updatedItem?.canvasEnrollmentId, originalEnrollmentId)
    }

    func testWriteWithNilResponse() {
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        let item: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        let originalEnrollmentId = item?.canvasEnrollmentId

        testee = LearningLibraryEnrollUseCase(id: "item-1", itemID: "course-123")
        testee.write(response: nil, urlResponse: nil, to: databaseClient)

        let updatedItem: CDHLearningLibraryCollectionItem? = databaseClient.first(
            where: #keyPath(CDHLearningLibraryCollectionItem.itemId),
            equals: "course-123"
        )
        XCTAssertEqual(updatedItem?.canvasEnrollmentId, originalEnrollmentId)
    }
}
