//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct GetHActivitiesWidgetResponse: Codable {
    public let data: Response?

    public struct Response: Codable {
        public let widgetData: WidgetData?
    }

    public struct WidgetData: Codable {
        public let data: [Widget]?
        let lastModifiedDate: String?
    }

    public struct Widget: Codable {
        let courseID: Int?
        let courseName: String?
        let userID: Int?
        let userUUID, userName, userAvatarImageURL, userEmail: String?
        let moduleCountCompleted, moduleCountStarted, moduleCountLocked, moduleCountTotal: Int?

        enum CodingKeys: String, CodingKey {
            case courseID = "course_id"
            case courseName = "course_name"
            case userID = "user_id"
            case userUUID = "user_uuid"
            case userName = "user_name"
            case userAvatarImageURL = "user_avatar_image_url"
            case userEmail = "user_email"
            case moduleCountCompleted = "module_count_completed"
            case moduleCountStarted = "module_count_started"
            case moduleCountLocked = "module_count_locked"
            case moduleCountTotal = "module_count_total"
        }
    }
}
