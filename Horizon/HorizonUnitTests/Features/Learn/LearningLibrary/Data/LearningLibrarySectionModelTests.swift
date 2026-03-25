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

final class LearningLibrarySectionModelTests: HorizonTestCase {

    func testInitWithParameters() {
        let items = [
            createMockCard(name: "Course A"),
            createMockCard(name: "Course B")
        ]
        let section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            hasMoreItems: true,
            totalItemCount: "10",
            items: items
        )

        XCTAssertEqual(section.id, "section-1")
        XCTAssertEqual(section.name, "Featured")
        XCTAssertTrue(section.hasMoreItems)
        XCTAssertEqual(section.totalItemCount, "10")
        XCTAssertEqual(section.items.count, 2)
    }

    func testInitWithDefaultValues() {
        let section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            items: []
        )

        XCTAssertFalse(section.hasMoreItems)
        XCTAssertEqual(section.totalItemCount, "")
    }

    func testInitFromCoreDataEntity() {
        let collectionJSON = """
        {
            "id": "collection-1",
            "name": "Featured Collection",
            "publicName": "Featured",
            "description": "Description",
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-02-01T00:00:00Z",
            "totalItemCount": 5,
            "items": [
                {
                    "id": "item-1",
                    "libraryId": "collection-1",
                    "itemType": "COURSE",
                    "displayOrder": 1,
                    "canvasCourse": {
                        "courseId": "course-123",
                        "courseName": "Swift Course"
                    }
                }
            ]
        }
        """
        let collection = try! JSONDecoder().decode(GetHLearningLibraryCollectionResponse.Collection.self, from: collectionJSON.data(using: .utf8)!)
        let entity = CDHLearningLibraryCollection.save(collection, in: databaseClient)

        let section = LearningLibrarySectionModel(
            for: entity,
            hasMoreItems: true,
            items: Array(entity.items)
        )

        XCTAssertEqual(section.id, "collection-1")
        XCTAssertEqual(section.name, "Featured Collection")
        XCTAssertTrue(section.hasMoreItems)
        XCTAssertEqual(section.totalItemCount, "5")
        XCTAssertEqual(section.items.count, 1)
    }

    func testSortedItemsSortsByName() {
        let items = [
            createMockCard(name: "Zebra Course"),
            createMockCard(name: "Apple Course"),
            createMockCard(name: "Mango Course"),
            createMockCard(name: "Banana Course")
        ]
        let section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            items: items
        )

        let sortedItems = section.sortedItems

        XCTAssertEqual(sortedItems[0].name, "Apple Course")
        XCTAssertEqual(sortedItems[1].name, "Banana Course")
        XCTAssertEqual(sortedItems[2].name, "Mango Course")
        XCTAssertEqual(sortedItems[3].name, "Zebra Course")
    }

    func testSortedItemsCaseInsensitive() {
        let items = [
            createMockCard(name: "zebra course"),
            createMockCard(name: "Apple Course"),
            createMockCard(name: "MANGO COURSE")
        ]
        let section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            items: items
        )

        let sortedItems = section.sortedItems

        XCTAssertEqual(sortedItems[0].name, "Apple Course")
        XCTAssertEqual(sortedItems[1].name, "MANGO COURSE")
        XCTAssertEqual(sortedItems[2].name, "zebra course")
    }

    func testUpdateItemUpdatesExistingItem() {
        let item1 = createMockCard(id: "item-1", name: "Course A", isBookmarked: false)
        let item2 = createMockCard(id: "item-2", name: "Course B", isBookmarked: false)
        var section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            items: [item1, item2]
        )

        let updatedItem = createMockCard(id: "item-1", name: "Course A", isBookmarked: true)
        section.update(item: updatedItem)

        XCTAssertEqual(section.items.count, 2)
        XCTAssertTrue(updatedItem.isBookmarked)
        XCTAssertFalse(section.items[1].isBookmarked)
    }

    func testUpdateItemDoesNothingForNonExistentItem() {
        let item1 = createMockCard(id: "item-1", name: "Course A")
        var section = LearningLibrarySectionModel(
            id: "section-1",
            name: "Featured",
            items: [item1]
        )

        let nonExistentItem = createMockCard(id: "item-999", name: "Course Z")
        section.update(item: nonExistentItem)

        XCTAssertEqual(section.items.count, 1)
        XCTAssertEqual(section.items[0].id, "item-1")
    }

    // MARK: - Helper Methods

    private func createMockCard(
        id: String = "item-1",
        name: String,
        isBookmarked: Bool = false
    ) -> LearningLibraryCardModel {
        LearningLibraryCardModel(
            id: id,
            courseID: "course-\(id)",
            name: name,
            imageURL: nil,
            itemType: .course,
            estimatedTime: "60",
            isRecommended: false,
            isCompleted: false,
            isBookmarked: isBookmarked,
            numberOfUnits: 5,
            isEnrolled: false
        )
    }
}
