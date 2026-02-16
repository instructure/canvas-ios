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

import Foundation

protocol LearningLibraryItemQueryable {
    static var itemsQuery: String { get }
    static var itemQuery: String { get }
}

extension LearningLibraryItemQueryable {
    static var itemsQuery: String {
        """
        items {
         \(value)
        }
        """
    }

    static var itemQuery: String {
        """
        item {
         \(value)
        }
        """
    }

    static private var value: String {
        """
        id
        libraryId
        itemType
        displayOrder
        isBookmarked
        completionPercentage
        isEnrolledInCanvas
        createdAt
        updatedAt
        canvasEnrollmentId
        canvasCourse {
          courseId
          courseName
          canvasUrl
          courseImageUrl
          moduleCount
          moduleItemCount
          estimatedDurationMinutes
        }
        programId
        programCourseId
        """
    }
}
