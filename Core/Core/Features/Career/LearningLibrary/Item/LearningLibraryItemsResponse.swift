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
    public let id: String
    public let libraryId: String?
    public let itemType: String
    public let displayOrder: Int?
    public let isBookmarked: Bool?
    public let completionPercentage: Double?
    public let isEnrolledInCanvas: Bool?
    public let createdAt: String?
    public let updatedAt: String?
    public let canvasModuleId: String?
    public let canvasModuleItemId: String?
    public let canvasCourse: CanvasCourse?
    public let programId: String?
    public let programCourseId: String?
    public let canvasEnrollmentId: String?

    public struct CanvasCourse: Codable {
        public let courseId: String
        public let courseName: String
        public let canvasUrl: String?
        public let courseImageUrl: String?
        public let moduleCount: Int?
        public let moduleItemCount: Int?
        public let estimatedDurationMinutes: Int?
    }
}
