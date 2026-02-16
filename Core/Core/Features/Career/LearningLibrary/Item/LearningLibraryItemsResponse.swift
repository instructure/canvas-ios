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

public struct LearningLibraryItemsResponse: Codable {
    let id: String
    let libraryId: String?
    let itemType: String
    let displayOrder: Int?
    let isBookmarked: Bool?
    let completionPercentage: Double?
    let isEnrolledInCanvas: Bool?
    let createdAt: String?
    let updatedAt: String?
    let canvasCourse: CanvasCourse?
    let programId: String?
    let programCourseId: String?
    let canvasEnrollmentId: String?

    struct CanvasCourse: Codable {
        let courseId: String
        let courseName: String
        let canvasUrl: String?
        let courseImageUrl: String?
        let moduleCount: Int?
        let moduleItemCount: Int?
        let estimatedDurationMinutes: Int?
    }
}
