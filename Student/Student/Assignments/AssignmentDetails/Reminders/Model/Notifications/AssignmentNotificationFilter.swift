//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import UserNotifications

extension Sequence where Element == UNNotificationRequest {

    public func filter(courseId: String,
                       assignmentId: String,
                       userId: String) -> [UNNotificationRequest] {
        filter {
            let userInfo = $0.content.userInfo
            return userInfo[UNMutableNotificationContent.Keys.courseId.rawValue] as? String == courseId &&
                   userInfo[UNMutableNotificationContent.Keys.assignmentId.rawValue] as? String == assignmentId &&
                   userInfo[UNMutableNotificationContent.Keys.userId.rawValue] as? String == userId
        }
    }
}
