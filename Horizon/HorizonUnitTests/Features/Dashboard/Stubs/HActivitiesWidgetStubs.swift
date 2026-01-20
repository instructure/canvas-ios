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
@testable import Core

enum HActivitiesWidgetStubs {
    static let token = "test-token"

    static let response = GetHActivitiesWidgetResponse(
        data: .init(
            widgetData: .init(
                data: [
                    .init(
                        courseID: "101",
                        courseName: "Course 1",
                        userID: "1",
                        userUUID: "uuid1",
                        userName: "User 1",
                        userAvatarImageURL: "avatar1",
                        userEmail: "user1@test.com",
                        moduleCountCompleted: 5,
                        moduleCountStarted: 2,
                        moduleCountLocked: 1,
                        moduleCountTotal: 8
                    ),
                    .init(
                        courseID: "102",
                        courseName: "Course 2",
                        userID: "1",
                        userUUID: "uuid1",
                        userName: "User 1",
                        userAvatarImageURL: "avatar1",
                        userEmail: "user1@test.com",
                        moduleCountCompleted: 3,
                        moduleCountStarted: 1,
                        moduleCountLocked: 2,
                        moduleCountTotal: 6
                    ),
                    .init(
                        courseID: "103",
                        courseName: "Course 3",
                        userID: "1",
                        userUUID: "uuid1",
                        userName: "User 1",
                        userAvatarImageURL: "avatar1",
                        userEmail: "user1@test.com",
                        moduleCountCompleted: 8,
                        moduleCountStarted: 0,
                        moduleCountLocked: 0,
                        moduleCountTotal: 8
                    )
                ],
                lastModifiedDate: "2025-10-18"
            )
        )
    )
}
