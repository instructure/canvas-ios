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

@testable import Core
import XCTest

final class GetHLearningLibraryItemResponseTests: CoreTestCase {
    func testDecodingCompleteResponse() throws {
        let jsonString = """
        {
            "data": {
                "learningLibraryCollectionItems": {
                    "items": [
                        {
                            "id": "item-1",
                            "libraryId": "library-1",
                            "itemType": "COURSE",
                            "displayOrder": 1,
                            "isBookmarked": true,
                            "completionPercentage": 0.75,
                            "isEnrolledInCanvas": true,
                            "createdAt": "2026-01-01T00:00:00Z",
                            "updatedAt": "2026-02-01T00:00:00Z",
                            "canvasEnrollmentId": "enrollment-1",
                            "canvasCourse": {
                                "courseId": "course-123",
                                "courseName": "Introduction to Swift",
                                "canvasUrl": "https://canvas.example.com/courses/123",
                                "courseImageUrl": "https://canvas.example.com/images/course.jpg",
                                "moduleCount": 5,
                                "moduleItemCount": 20,
                                "estimatedDurationMinutes": 180
                            },
                            "programId": "program-789",
                            "programCourseId": "program-course-012"
                        },
                        {
                            "id": "item-2",
                            "libraryId": "library-2",
                            "itemType": "PAGE",
                            "displayOrder": 2,
                            "isBookmarked": false,
                            "completionPercentage": 0.0,
                            "isEnrolledInCanvas": false,
                            "createdAt": "2026-01-15T00:00:00Z",
                            "updatedAt": "2026-02-15T00:00:00Z",
                            "canvasCourse": {
                                "courseId": "course-456",
                                "courseName": "Advanced Topics",
                                "canvasUrl": "https://canvas.example.com/courses/456",
                                "moduleCount": 3,
                                "moduleItemCount": 10,
                                "estimatedDurationMinutes": 90
                            }
                        }
                    ]
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GetHLearningLibraryItemResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        XCTAssertNotNil(response.data?.learningLibraryCollectionItems)

        let items = response.data?.learningLibraryCollectionItems?.items
        XCTAssertEqual(items?.count, 2)

        let firstItem = items?.first
        XCTAssertEqual(firstItem?.id, "item-1")
        XCTAssertEqual(firstItem?.libraryId, "library-1")
        XCTAssertEqual(firstItem?.itemType, "COURSE")
        XCTAssertEqual(firstItem?.displayOrder, 1)
        XCTAssertEqual(firstItem?.isBookmarked, true)
        XCTAssertEqual(firstItem?.completionPercentage, 0.75)
        XCTAssertEqual(firstItem?.isEnrolledInCanvas, true)
        XCTAssertEqual(firstItem?.createdAt, "2026-01-01T00:00:00Z")
        XCTAssertEqual(firstItem?.updatedAt, "2026-02-01T00:00:00Z")
        XCTAssertEqual(firstItem?.canvasEnrollmentId, "enrollment-1")
        XCTAssertEqual(firstItem?.canvasCourse?.courseId, "course-123")
        XCTAssertEqual(firstItem?.canvasCourse?.courseName, "Introduction to Swift")
        XCTAssertEqual(firstItem?.canvasCourse?.canvasUrl?.absoluteString, "https://canvas.example.com/courses/123")
        XCTAssertEqual(firstItem?.canvasCourse?.courseImageUrl, "https://canvas.example.com/images/course.jpg")
        XCTAssertEqual(firstItem?.canvasCourse?.moduleCount, 5)
        XCTAssertEqual(firstItem?.canvasCourse?.moduleItemCount, 20)
        XCTAssertEqual(firstItem?.canvasCourse?.estimatedDurationMinutes, 180)
        XCTAssertEqual(firstItem?.programId, "program-789")
        XCTAssertEqual(firstItem?.programCourseId, "program-course-012")

        let secondItem = items?.last
        XCTAssertEqual(secondItem?.id, "item-2")
        XCTAssertEqual(secondItem?.libraryId, "library-2")
        XCTAssertEqual(secondItem?.itemType, "PAGE")
        XCTAssertEqual(secondItem?.displayOrder, 2)
        XCTAssertEqual(secondItem?.isBookmarked, false)
        XCTAssertEqual(secondItem?.completionPercentage, 0.0)
        XCTAssertEqual(secondItem?.isEnrolledInCanvas, false)
        XCTAssertNil(secondItem?.canvasEnrollmentId)
        XCTAssertNil(secondItem?.programId)
        XCTAssertNil(secondItem?.programCourseId)
    }

    func testDecodingPartialResponse() throws {
        let jsonString = """
        {
            "data": {
                "learningLibraryCollectionItems": {
                    "items": [
                        {
                            "id": "item-1",
                            "libraryId": "library-1",
                            "itemType": "COURSE"
                        }
                    ],
                    "pageInfo": {
                        "hasNextPage": false,
                        "hasPreviousPage": false
                    }
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GetHLearningLibraryItemResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        let items = response.data?.learningLibraryCollectionItems?.items
        XCTAssertEqual(items?.count, 1)

        let item = items?.first
        XCTAssertEqual(item?.id, "item-1")
        XCTAssertEqual(item?.libraryId, "library-1")
        XCTAssertEqual(item?.itemType, "COURSE")
        XCTAssertNil(item?.displayOrder)
        XCTAssertNil(item?.isBookmarked)
        XCTAssertNil(item?.completionPercentage)
        XCTAssertNil(item?.isEnrolledInCanvas)
        XCTAssertNil(item?.createdAt)
        XCTAssertNil(item?.updatedAt)
        XCTAssertNil(item?.canvasCourse)
        XCTAssertNil(item?.programId)
        XCTAssertNil(item?.programCourseId)
        XCTAssertNil(item?.canvasEnrollmentId)

        let pageInfo = response.data?.learningLibraryCollectionItems?.pageInfo
        XCTAssertNil(pageInfo?.nextCursor)
        XCTAssertNil(pageInfo?.previousCursor)
        XCTAssertEqual(pageInfo?.hasNextPage, false)
        XCTAssertEqual(pageInfo?.hasPreviousPage, false)
    }

    func testEmptyItemsResponse() throws {
        let jsonString = """
        {
            "data": {
                "learningLibraryCollectionItems": {
                    "items": [],
                    "pageInfo": {
                        "hasNextPage": false,
                        "hasPreviousPage": false
                    }
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GetHLearningLibraryItemResponse.self, from: jsonData)

        XCTAssertNotNil(response.data)
        XCTAssertNotNil(response.data?.learningLibraryCollectionItems)
        XCTAssertEqual(response.data?.learningLibraryCollectionItems?.items?.count, 0)
    }

    func testNullDataResponse() throws {
        let jsonString = """
        {
            "data": null
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()

        let response = try decoder.decode(GetHLearningLibraryItemResponse.self, from: jsonData)

        XCTAssertNil(response.data)
    }

    func testPagePropertyWithItems() {
        let response = GetHLearningLibraryItemResponse(
            data: .init(
                learningLibraryCollectionItems: .init(
                    items: [
                        LearningLibraryStubs.learningLibraryItem
                    ],
                    pageInfo: .init(
                        nextCursor: nil,
                        previousCursor: nil,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )
                )
            )
        )

        XCTAssertEqual(response.page.count, 1)
        XCTAssertEqual(response.page.first?.id, LearningLibraryStubs.learningLibraryItem.id)
    }

    func testPagePropertyWithNullItems() {
        let response = GetHLearningLibraryItemResponse(
            data: .init(
                learningLibraryCollectionItems: .init(
                    items: nil,
                    pageInfo: nil
                )
            )
        )

        XCTAssertEqual(response.page.count, 0)
    }

    func testPagePropertyWithNullData() {
        let response = GetHLearningLibraryItemResponse(data: nil)

        XCTAssertEqual(response.page.count, 0)
    }
}
