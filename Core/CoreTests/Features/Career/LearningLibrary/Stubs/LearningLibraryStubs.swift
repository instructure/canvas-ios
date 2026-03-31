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
import Foundation

enum LearningLibraryStubs {
    static let canvasCourse = LearningLibraryItemsResponse.CanvasCourse(
        courseId: "course-123",
        courseName: "Introduction to Swift",
        canvasUrl: URL(string: "https://canvas.example.com/courses/123"),
        courseImageUrl: "https://canvas.example.com/images/course.jpg",
        moduleCount: 5,
        moduleItemCount: 20,
        estimatedDurationMinutes: 180
    )

    static let learningLibraryItem = LearningLibraryItemsResponse(
        id: "item-123",
        libraryId: "library-456",
        itemType: "course",
        displayOrder: 1,
        isBookmarked: true,
        completionPercentage: 0.65,
        isEnrolledInCanvas: true,
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-02-01T00:00:00Z",
        canvasModuleId: "11",
        canvasModuleItemId: "21",
        canvasCourse: canvasCourse,
        programId: "program-789",
        programCourseId: "program-course-012",
        canvasEnrollmentId: "enrollment-345"
    )

    static let collection = GetHLearningLibraryCollectionResponse.Collection(
        id: "collection-123",
        name: "Featured Collection",
        publicName: "Featured Learning Path",
        description: "A curated collection of courses",
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-02-01T00:00:00Z",
        totalItemCount: 4,
        items: [learningLibraryItem]
    )

    static let collectionWithNilValues = GetHLearningLibraryCollectionResponse.Collection(
        id: "collection-123",
        name: "Featured Collection",
        publicName: "Featured Learning Path",
        description: nil,
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-02-01T00:00:00Z",
        totalItemCount: nil,
        items: nil
    )
}
