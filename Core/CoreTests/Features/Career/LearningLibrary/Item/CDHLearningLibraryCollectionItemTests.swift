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

final class CDHLearningLibraryCollectionItemTests: CoreTestCase {
    func testSave() {
        let apiEntity = LearningLibraryStubs.learningLibraryItem

        let savedEntity = CDHLearningLibraryCollectionItem.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, LearningLibraryStubs.learningLibraryItem.id)
        XCTAssertEqual(savedEntity.completionPercentage, LearningLibraryStubs.learningLibraryItem.completionPercentage ?? 0)
        XCTAssertEqual(savedEntity.displayOrder, NSNumber(value: LearningLibraryStubs.learningLibraryItem.displayOrder ?? 0))
        XCTAssertEqual(savedEntity.estimatedDurationMinutes, NSNumber(value: LearningLibraryStubs.canvasCourse.estimatedDurationMinutes ?? 0))
        XCTAssertEqual(savedEntity.imageUrl, LearningLibraryStubs.canvasCourse.courseImageUrl)
        XCTAssertEqual(savedEntity.isBookmarked, LearningLibraryStubs.learningLibraryItem.isBookmarked ?? false)
        XCTAssertEqual(savedEntity.isEnrolledInCanvas, LearningLibraryStubs.learningLibraryItem.isEnrolledInCanvas ?? false)
        XCTAssertEqual(savedEntity.courseID, LearningLibraryStubs.canvasCourse.courseId)
        XCTAssertEqual(savedEntity.itemType, LearningLibraryStubs.learningLibraryItem.itemType)
        XCTAssertEqual(savedEntity.libraryId, LearningLibraryStubs.learningLibraryItem.libraryId ?? "")
        XCTAssertEqual(savedEntity.moduleCount, NSNumber(value: LearningLibraryStubs.canvasCourse.moduleCount ?? 0))
        XCTAssertEqual(savedEntity.moduleItemCount, NSNumber(value: LearningLibraryStubs.canvasCourse.moduleItemCount ?? 0))
        XCTAssertEqual(savedEntity.name, LearningLibraryStubs.canvasCourse.courseName)
        XCTAssertEqual(savedEntity.programCourseId, LearningLibraryStubs.learningLibraryItem.programCourseId ?? "")
        XCTAssertEqual(savedEntity.programId, LearningLibraryStubs.learningLibraryItem.programId ?? "")
        XCTAssertEqual(savedEntity.canvasEnrollmentId, LearningLibraryStubs.learningLibraryItem.canvasEnrollmentId)
    }

    func testSaveWithNilCanvasCourse() {
        let apiEntity = LearningLibraryItemsResponse(
            id: "item-456",
            libraryId: "library-789",
            itemType: "page",
            displayOrder: nil,
            isBookmarked: nil,
            completionPercentage: nil,
            isEnrolledInCanvas: nil,
            createdAt: nil,
            updatedAt: nil,
            canvasModuleId: nil,
            canvasModuleItemId: nil,
            canvasCourse: nil,
            programId: nil,
            programCourseId: nil,
            canvasEnrollmentId: nil
        )

        let savedEntity = CDHLearningLibraryCollectionItem.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, "item-456")
        XCTAssertEqual(savedEntity.completionPercentage, 0)
        XCTAssertEqual(savedEntity.displayOrder, NSNumber(value: 0))
        XCTAssertNil(savedEntity.estimatedDurationMinutes)
        XCTAssertNil(savedEntity.imageUrl)
        XCTAssertFalse(savedEntity.isBookmarked)
        XCTAssertFalse(savedEntity.isEnrolledInCanvas)
        XCTAssertEqual(savedEntity.courseID, "")
        XCTAssertEqual(savedEntity.itemType, "page")
        XCTAssertEqual(savedEntity.libraryId, "library-789")
        XCTAssertNil(savedEntity.moduleCount)
        XCTAssertNil(savedEntity.moduleItemCount)
        XCTAssertEqual(savedEntity.name, "")
        XCTAssertEqual(savedEntity.programCourseId, "")
        XCTAssertEqual(savedEntity.programId, "")
        XCTAssertNil(savedEntity.canvasEnrollmentId)
    }

    func testSaveWithZeroModuleCounts() {
        let apiEntity = LearningLibraryItemsResponse(
            id: "item-789",
            libraryId: "library-012",
            itemType: "course",
            displayOrder: 1,
            isBookmarked: false,
            completionPercentage: 0.0,
            isEnrolledInCanvas: false,
            createdAt: "2026-01-01T00:00:00Z",
            updatedAt: "2026-02-01T00:00:00Z",
            canvasModuleId: "12",
            canvasModuleItemId: "1212",
            canvasCourse: LearningLibraryItemsResponse.CanvasCourse(
                courseId: "course-345",
                courseName: "Test Course",
                canvasUrl: "https://canvas.example.com",
                courseImageUrl: nil,
                moduleCount: 0,
                moduleItemCount: 0,
                estimatedDurationMinutes: 60
            ),
            programId: nil,
            programCourseId: nil,
            canvasEnrollmentId: nil
        )

        let savedEntity = CDHLearningLibraryCollectionItem.save(apiEntity, in: databaseClient)

        XCTAssertNil(savedEntity.moduleCount)
        XCTAssertNil(savedEntity.moduleItemCount)
    }

    func testUpdateBookmark() {
        let apiEntity = LearningLibraryStubs.learningLibraryItem
        let savedEntity = CDHLearningLibraryCollectionItem.save(apiEntity, in: databaseClient)
        XCTAssertTrue(savedEntity.isBookmarked)

        CDHLearningLibraryCollectionItem.updateBookmark(
            courseID: savedEntity.courseID,
            isBookmarked: false,
            in: databaseClient
        )

        XCTAssertFalse(savedEntity.isBookmarked)
    }

    func testUpdateEnroll() {
        let apiEntity = LearningLibraryStubs.learningLibraryItem
        let savedEntity = CDHLearningLibraryCollectionItem.save(apiEntity, in: databaseClient)
        XCTAssertTrue(savedEntity.isEnrolledInCanvas)
        XCTAssertEqual(savedEntity.canvasEnrollmentId, "enrollment-345")

        CDHLearningLibraryCollectionItem.updateEnroll(
            courseID: savedEntity.courseID,
            enrollmentID: "new-enrollment-678",
            in: databaseClient
        )

        XCTAssertTrue(savedEntity.isEnrolledInCanvas)
        XCTAssertEqual(savedEntity.canvasEnrollmentId, "new-enrollment-678")
    }
}
