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

@testable import Core
@testable import Horizon

enum HTimeSpentWidgetStubs {
    static let token = "test_token_time"
    static let response = GetTimeSpentWidgetResponse(
        data: .init(
            widgetData: .init(
                data: [
                    .init(
                        date: nil,
                        userID: nil,
                        userUUID: nil,
                        userName: nil,
                        userEmail: nil,
                        userAvatarImageURL: nil,
                        courseID: "C1",
                        courseName: "Course 1",
                        minutesPerDay: 10
                    ),
                    .init(
                        date: nil,
                        userID: nil,
                        userUUID: nil,
                        userName: nil,
                        userEmail: nil,
                        userAvatarImageURL: nil,
                        courseID: "C2",
                        courseName: "Course 2",
                        minutesPerDay: 20
                    ),
                    .init(
                        date: nil,
                        userID: nil,
                        userUUID: nil,
                        userName: nil,
                        userEmail: nil,
                        userAvatarImageURL: nil,
                        courseID: "C1",
                        courseName: "Course 1",
                        minutesPerDay: 5
                    ),
                    // Entry with nil minutes (defaults to 0)
                    .init(
                        date: nil,
                        userID: nil,
                        userUUID: nil,
                        userName: nil,
                        userEmail: nil,
                        userAvatarImageURL: nil,
                        courseID: "C3",
                        courseName: "Course 3",
                        minutesPerDay: nil
                    ),
                    // Entry with nil courseID should be ignored
                    .init(
                        date: nil,
                        userID: nil,
                        userUUID: nil,
                        userName: nil,
                        userEmail: nil,
                        userAvatarImageURL: nil,
                        courseID: nil,
                        courseName: "No ID Course",
                        minutesPerDay: 50
                    )
                ],
                lastModifiedDate: "2025-01-01"
            )
        )
    )
}
