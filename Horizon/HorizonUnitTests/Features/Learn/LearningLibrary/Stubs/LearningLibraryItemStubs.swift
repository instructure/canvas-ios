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

import Core
import Foundation

enum LearningLibraryItemStubs {
    static let bookmarkedItem1: LearningLibraryItemsResponse = {
        let json = """
        {
            "id": "item-1",
            "libraryId": "library-1",
            "itemType": "COURSE",
            "displayOrder": 1,
            "isBookmarked": true,
            "completionPercentage": 0.65,
            "isEnrolledInCanvas": true,
            "createdAt": "2026-01-01T00:00:00Z",
            "updatedAt": "2026-02-01T00:00:00Z",
            "canvasCourse": {
                "courseId": "course-123",
                "courseName": "Introduction to Swift",
                "canvasUrl": "https://canvas.example.com/courses/123",
                "courseImageUrl": "https://canvas.example.com/images/course1.jpg",
                "moduleCount": 5,
                "moduleItemCount": 20,
                "estimatedDurationMinutes": 180
            },
            "programId": "program-789",
            "programCourseId": "program-course-012",
            "canvasEnrollmentId": "enrollment-123"
        }
        """
        return try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: json.data(using: .utf8)!)
    }()

    static let bookmarkedItem2: LearningLibraryItemsResponse = {
        let json = """
        {
            "id": "item-2",
            "libraryId": "library-2",
            "itemType": "COURSE",
            "displayOrder": 2,
            "isBookmarked": true,
            "completionPercentage": 0.30,
            "isEnrolledInCanvas": false,
            "createdAt": "2026-01-15T00:00:00Z",
            "updatedAt": "2026-02-15T00:00:00Z",
            "canvasCourse": {
                "courseId": "course-456",
                "courseName": "Advanced SwiftUI",
                "canvasUrl": "https://canvas.example.com/courses/456",
                "courseImageUrl": "https://canvas.example.com/images/course2.jpg",
                "moduleCount": 3,
                "moduleItemCount": 15,
                "estimatedDurationMinutes": 120
            },
            "programId": "program-456",
            "programCourseId": "program-course-789"
        }
        """
        return try! JSONDecoder().decode(LearningLibraryItemsResponse.self, from: json.data(using: .utf8)!)
    }()

    static let canvasCourse1: LearningLibraryItemsResponse.CanvasCourse = bookmarkedItem1.canvasCourse!
    static let canvasCourse2: LearningLibraryItemsResponse.CanvasCourse = bookmarkedItem2.canvasCourse!

    static let response: [LearningLibraryItemsResponse] = [
        bookmarkedItem1,
        bookmarkedItem2
    ]
}
