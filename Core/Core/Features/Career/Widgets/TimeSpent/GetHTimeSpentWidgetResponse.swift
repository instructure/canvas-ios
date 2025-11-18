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

public struct GetHTimeSpentWidgetResponse: Codable {
    public let data: Response?

    public struct Response: Codable {
        public let widgetData: WidgetData?
    }

    public struct WidgetData: Codable {
        public let data: [TimeSpent]?
        let lastModifiedDate: String?
    }

    public struct TimeSpent: Codable {
        let date: String?
        let userID: Int?
        let userUUID, userName, userEmail, userAvatarImageURL: String?
        public let courseID: String?
        public let courseName: String?
        public var minutesPerDay: Int?

        enum CodingKeys: String, CodingKey {
            case date
            case userID = "user_id"
            case userUUID = "user_uuid"
            case userName = "user_name"
            case userEmail = "user_email"
            case userAvatarImageURL = "user_avatar_image_url"
            case courseID = "course_id"
            case courseName = "course_name"
            case minutesPerDay = "minutes_per_day"
        }

        public init(
            date: String?,
            userID: Int?,
            userUUID: String?,
            userName: String?,
            userEmail: String?,
            userAvatarImageURL: String?,
            courseID: String?,
            courseName: String?,
            minutesPerDay: Int?
        ) {
            self.date = date
            self.userID = userID
            self.userUUID = userUUID
            self.userName = userName
            self.userEmail = userEmail
            self.userAvatarImageURL = userAvatarImageURL
            self.courseID = courseID
            self.courseName = courseName
            self.minutesPerDay = minutesPerDay
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            date = try container.decodeIfPresent(String.self, forKey: .date)
            userID = try container.decodeIfPresent(Int.self, forKey: .userID)
            userUUID = try container.decodeIfPresent(String.self, forKey: .userUUID)
            userName = try container.decodeIfPresent(String.self, forKey: .userName)
            userEmail = try container.decodeIfPresent(String.self, forKey: .userEmail)
            userAvatarImageURL = try container.decodeIfPresent(String.self, forKey: .userAvatarImageURL)
            courseName = try container.decodeIfPresent(String.self, forKey: .courseName)
            minutesPerDay = try container.decodeIfPresent(Int.self, forKey: .minutesPerDay)

            if let intValue = try? container.decode(Int.self, forKey: .courseID) {
                courseID = String(intValue)
            } else if let stringValue = try? container.decode(String.self, forKey: .courseID), !stringValue.isEmpty {
                courseID = stringValue
            } else {
                courseID = nil
            }
        }
    }
}
