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
import TestsFoundation

final class LearningLibraryInteractorTests: HorizonTestCase {

    // MARK: - Get Learning Library Collections Tests

    func testGetLearnLibraryCollectionsReturnsMultipleCollections() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockCollectionsResponse(collectionCount: 3)

        XCTAssertSingleOutputAndFinish(testee.getLearnLibraryCollections(ignoreCache: false)) { sections in
            XCTAssertEqual(sections.count, 3)
            XCTAssertEqual(sections[0].items.count, 2)
        }
    }

    func testGetLearnLibraryCollectionsSingleCollectionReturns4Items() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockCollectionsResponse(collectionCount: 1)

        XCTAssertSingleOutputAndFinish(testee.getLearnLibraryCollections(ignoreCache: false)) { sections in
            XCTAssertEqual(sections.count, 1)
            XCTAssertEqual(sections[0].items.count, 4)
        }
    }

    func testGetLearnLibraryCollectionsReturnsEmptyWhenNoCollections() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockEmptyCollectionsResponse()

        XCTAssertSingleOutputAndFinish(testee.getLearnLibraryCollections(ignoreCache: false)) { sections in
            XCTAssertEqual(sections.count, 0)
        }
    }

    func testGetLearnLibraryCollectionsSortsItemsByName() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockCollectionsResponse(collectionCount: 1)

        XCTAssertSingleOutputAndFinish(testee.getLearnLibraryCollections(ignoreCache: false)) { sections in
            let section = sections.first
            XCTAssertNotNil(section)
            if let items = section?.items, items.count > 1 {
                for i in 0..<items.count - 1 {
                    XCTAssertLessThanOrEqual(items[i].name, items[i + 1].name)
                }
            }
        }
    }

    func testGetLearnLibraryCollectionsIgnoresCacheWhenRequested() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockCollectionsResponse(collectionCount: 2)

        XCTAssertSingleOutputAndFinish(testee.getLearnLibraryCollections(ignoreCache: true)) { sections in
            XCTAssertEqual(sections.count, 2)
        }
    }

    // MARK: - Get Bookmarked Items Tests

    func testGetBookmarkedItemsReturnsBookmarkedItems() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockBookmarkedItemsResponse()

        XCTAssertSingleOutputAndFinish(testee.getBookmarkedItems(ignoreCache: false)) { items in
            XCTAssertEqual(items.count, 2)
            XCTAssertTrue(items.allSatisfy { $0.isBookmarked })
        }
    }

    func testGetBookmarkedItemsReturnsEmptyWhenNoBookmarks() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockEmptyBookmarkedItemsResponse()

        XCTAssertSingleOutputAndFinish(testee.getBookmarkedItems(ignoreCache: false)) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    func testGetBookmarkedItemsRemovesDuplicates() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockBookmarkedItemsWithDuplicates()

        XCTAssertSingleOutputAndFinish(testee.getBookmarkedItems(ignoreCache: false)) { items in
            let uniqueItemIds = Set(items.map { $0.courseID })
            XCTAssertEqual(items.count, uniqueItemIds.count)
        }
    }

    func testGetBookmarkedItemsIgnoresCacheWhenRequested() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockBookmarkedItemsResponse()

        XCTAssertSingleOutputAndFinish(testee.getBookmarkedItems(ignoreCache: true)) { items in
            XCTAssertGreaterThan(items.count, 0)
        }
    }

    // MARK: - Search Collection Item Tests

    func testSearchCollectionItemReturnsMatchingItems() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockSearchItemsResponse()

        XCTAssertSingleOutputAndFinish(
            testee.searchCollectionItem(
                bookmarkedOnly: false,
                completedOnly: false,
                types: nil,
                searchTerm: "Swift"
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 0)
        }
    }

    func testSearchCollectionItemWithBookmarkedOnlyFilter() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockSearchBookmarkedItemsResponse()

        XCTAssertSingleOutputAndFinish(
            testee.searchCollectionItem(
                bookmarkedOnly: true,
                completedOnly: false,
                types: nil,
                searchTerm: nil
            )
        ) { items in
            XCTAssertTrue(items.allSatisfy { $0.isBookmarked })
        }
    }

    func testSearchCollectionItemWithTypesFilter() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockSearchItemsWithTypes()

        XCTAssertSingleOutputAndFinish(
            testee.searchCollectionItem(
                bookmarkedOnly: false,
                completedOnly: false,
                types: ["COURSE"],
                searchTerm: nil
            )
        ) { items in
            XCTAssertGreaterThan(items.count, 0)
        }
    }

    func testSearchCollectionItemRemovesDuplicates() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockSearchItemsWithDuplicates()

        XCTAssertSingleOutputAndFinish(
            testee.searchCollectionItem(
                bookmarkedOnly: false,
                completedOnly: false,
                types: nil,
                searchTerm: nil
            )
        ) { items in
            let uniqueItemIds = Set(items.map { $0.courseID })
            XCTAssertEqual(items.count, uniqueItemIds.count)
        }
    }

    func testGetCollectionItemsReturnsEmptyWhenNoItems() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        mockEmptyCollectionItemsResponse(collectionId: "collection-456")

        XCTAssertSingleOutputAndFinish(testee.getCollectionItems(id: "collection-456", ignoreCache: false)) { items in
            XCTAssertEqual(items.count, 0)
        }
    }

    // MARK: - Bookmark Tests

    func testBookmarkTogglesItemBookmarkStatus() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        mockBookmarkToggleResponse(isBookmarked: false)

        XCTAssertSingleOutputAndFinish(testee.bookmark(id: "item-1", courseID: "course-123")) { item in
            XCTAssertNotNil(item)
            XCTAssertEqual(item?.id, "item-1")
        }
    }

    func testBookmarkReturnsUpdatedItem() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem2, in: databaseClient)
        mockBookmarkToggleResponse(isBookmarked: true)

        XCTAssertSingleOutputAndFinish(testee.bookmark(id: "item-2", courseID: "course-456")) { item in
            XCTAssertEqual(item?.courseID, "course-456")
        }
    }

    // MARK: - Enroll Tests

    func testEnrollEnrollsUserInItem() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem1, in: databaseClient)
        mockEnrollResponse(enrollmentId: "enrollment-999")

        XCTAssertSingleOutputAndFinish(testee.enroll(id: "item-1", courseID: "course-123")) { item in
            XCTAssertNotNil(item)
            XCTAssertEqual(item.id, "item-1")
        }
    }

    func testEnrollReturnsUpdatedItem() {
        let testee = LearningLibraryInteractorLive(domainService: DomainServiceMock(result: .success(api)))
        mockJWTToken()
        CDHLearningLibraryCollectionItem.save(LearningLibraryItemStubs.bookmarkedItem2, in: databaseClient)
        mockEnrollResponse(enrollmentId: "enrollment-888")

        XCTAssertSingleOutputAndFinish(testee.enroll(id: "item-2", courseID: "course-456")) { item in
            XCTAssertEqual(item.courseID, "course-456")
        }
    }

    // MARK: - Helper Methods

    private func mockJWTToken() {
        api.mock(
            DomainJWTService.JWTTokenRequest(),
            value: DomainJWTService.JWTTokenRequest.Result(token: "test-token")
        )
    }

    private func mockCollectionsResponse(collectionCount: Int) {
        var collections: [GetHLearningLibraryCollectionResponse.Collection] = []

        for i in 1...collectionCount {
            let collectionJSON = """
            {
                "id": "collection-\(i)",
                "name": "Collection \(i)",
                "publicName": "Public Collection \(i)",
                "description": "Description \(i)",
                "createdAt": "2026-01-01T00:00:00Z",
                "updatedAt": "2026-02-01T00:00:00Z",
                "totalItemCount": 6,
                "items": [
                    {
                        "id": "item-\(i)-1",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 1,
                        "canvasCourse": {
                            "courseId": "course-\(i)-1",
                            "courseName": "Zebra Course"
                        }
                    },
                    {
                        "id": "item-\(i)-2",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 2,
                        "canvasCourse": {
                            "courseId": "course-\(i)-2",
                            "courseName": "Apple Course"
                        }
                    },
                    {
                        "id": "item-\(i)-3",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 3,
                        "canvasCourse": {
                            "courseId": "course-\(i)-3",
                            "courseName": "Mango Course"
                        }
                    },
                    {
                        "id": "item-\(i)-4",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 4,
                        "canvasCourse": {
                            "courseId": "course-\(i)-4",
                            "courseName": "Banana Course"
                        }
                    },
                    {
                        "id": "item-\(i)-5",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 5,
                        "canvasCourse": {
                            "courseId": "course-\(i)-5",
                            "courseName": "Orange Course"
                        }
                    },
                    {
                        "id": "item-\(i)-6",
                        "libraryId": "collection-\(i)",
                        "itemType": "COURSE",
                        "displayOrder": 6,
                        "canvasCourse": {
                            "courseId": "course-\(i)-6",
                            "courseName": "Peach Course"
                        }
                    }
                ]
            }
            """
            let collection = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON.data(using: .utf8)!)
            collections.append(collection)
        }

        api.mock(
            GetHLearningLibraryCollectionRequest(),
            value: GetHLearningLibraryCollectionResponse(
                data: .init(
                    enrolledLearningLibraryCollections: .init(
                        collections: collections
                    )
                )
            )
        )
    }

    private func mockEmptyCollectionsResponse() {
        api.mock(
            GetHLearningLibraryCollectionRequest(),
            value: GetHLearningLibraryCollectionResponse(
                data: .init(
                    enrolledLearningLibraryCollections: .init(
                        collections: []
                    )
                )
            )
        )
    }

    private func mockBookmarkedItemsResponse() {
        api.mock(
            GetHLearningLibraryItemRequest(bookmarkedOnly: true),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: LearningLibraryItemStubs.response,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockEmptyBookmarkedItemsResponse() {
        api.mock(
            GetHLearningLibraryItemRequest(bookmarkedOnly: true),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: [],
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockBookmarkedItemsWithDuplicates() {
        let duplicateItems = LearningLibraryItemStubs.response + [LearningLibraryItemStubs.bookmarkedItem1]
        api.mock(
            GetHLearningLibraryItemRequest(bookmarkedOnly: true),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: duplicateItems,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockSearchItemsResponse() {
        api.mock(
            GetHLearningLibraryItemRequest(searchTerm: "Swift"),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: [LearningLibraryItemStubs.bookmarkedItem1],
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockSearchBookmarkedItemsResponse() {
        api.mock(
            GetHLearningLibraryItemRequest(bookmarkedOnly: true),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: LearningLibraryItemStubs.response,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockSearchItemsWithTypes() {
        api.mock(
            GetHLearningLibraryItemRequest(types: ["COURSE"]),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: LearningLibraryItemStubs.response,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockSearchItemsWithDuplicates() {
        let duplicateItems = LearningLibraryItemStubs.response + [LearningLibraryItemStubs.bookmarkedItem1]
        api.mock(
            GetHLearningLibraryItemRequest(),
            value: GetHLearningLibraryItemResponse(
                data: .init(
                    learningLibraryCollectionItems: .init(
                        items: duplicateItems,
                        pageInfo: nil
                    )
                )
            )
        )
    }

    private func mockCollectionItemsResponse(collectionId: String) {
        api.mock(
            GetHLearningLibraryCollectionItemRequest(id: collectionId),
            value: GetHLearningLibraryCollectionItemResponse(
                data: .init(
                    enrolledLearningLibraryCollection: .init(
                        id: collectionId,
                        name: "Test Collection",
                        publicName: "Public Collection",
                        description: nil,
                        createdAt: "2026-01-01T00:00:00Z",
                        updatedAt: "2026-02-01T00:00:00Z",
                        items: LearningLibraryItemStubs.response
                    )
                )
            )
        )
    }

    private func mockEmptyCollectionItemsResponse(collectionId: String) {
        api.mock(
            GetHLearningLibraryCollectionItemRequest(id: collectionId),
            value: GetHLearningLibraryCollectionItemResponse(
                data: .init(
                    enrolledLearningLibraryCollection: .init(
                        id: collectionId,
                        name: "Empty Collection",
                        publicName: "Empty",
                        description: nil,
                        createdAt: "2026-01-01T00:00:00Z",
                        updatedAt: "2026-02-01T00:00:00Z",
                        items: []
                    )
                )
            )
        )
    }

    private func mockBookmarkToggleResponse(isBookmarked: Bool) {
        api.mock(
            LearningLibraryBookMarkRequest(id: "item-1"),
            value: LearningLibraryBookMarkResponse(
                data: .init(
                    toggleCollectionItemBookmark: .init(isBookmarked: isBookmarked)
                )
            )
        )
        api.mock(
            LearningLibraryBookMarkRequest(id: "item-2"),
            value: LearningLibraryBookMarkResponse(
                data: .init(
                    toggleCollectionItemBookmark: .init(isBookmarked: isBookmarked)
                )
            )
        )
    }

    private func mockEnrollResponse(enrollmentId: String) {
        let enrolledItemJSON = """
        {
            "id": "item-1",
            "libraryId": "library-1",
            "itemType": "COURSE",
            "canvasCourse": {
                "courseId": "course-123",
                "courseName": "Introduction to Swift"
            },
            "canvasEnrollmentId": "\(enrollmentId)"
        }
        """
        let enrolledItem1 = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: enrolledItemJSON.data(using: .utf8)!)

        let enrolledItemJSON2 = """
        {
            "id": "item-2",
            "libraryId": "library-2",
            "itemType": "COURSE",
            "canvasCourse": {
                "courseId": "course-456",
                "courseName": "Advanced SwiftUI"
            },
            "canvasEnrollmentId": "\(enrollmentId)"
        }
        """
        let enrolledItem2 = try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: enrolledItemJSON2.data(using: .utf8)!)

        api.mock(
            LearningLibraryEnrollCollectionItemRequest(id: "item-1"),
            value: LearningLibraryEnrollCollectionItemResponse(
                data: .init(
                    enrollLearnerInCollectionItem: .init(
                        wasAlreadyEnrolled: false,
                        item: enrolledItem1
                    )
                )
            )
        )
        api.mock(
            LearningLibraryEnrollCollectionItemRequest(id: "item-2"),
            value: LearningLibraryEnrollCollectionItemResponse(
                data: .init(
                    enrollLearnerInCollectionItem: .init(
                        wasAlreadyEnrolled: false,
                        item: enrolledItem2
                    )
                )
            )
        )
    }
}
