//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import CoreData

public struct GetUserSettings: APIUseCase {
    public typealias Model = UserSettings

    public let userID: String

    public init (userID: String = "self") {
        self.userID = userID
    }

    public var cacheKey: String? {
        return "get-user-\(userID)-settings"
    }

    public var request: GetUserSettingsRequest {
        return GetUserSettingsRequest(userID: userID)
    }

    public var scope: Scope {
        return Scope(predicate: .all, order: [])
    }
}

public struct UpdateUserSettings: APIUseCase {
    public typealias Model = UserSettings

    public let cacheKey: String? = nil
    public let request: PutUserSettingsRequest
    public let scope = Scope(predicate: .all, order: [])

    public init(manual_mark_as_read: Bool? = nil, collapse_global_nav: Bool? = nil, hide_dashcard_color_overlays: Bool? = nil, comment_library_suggestions_enabled: Bool? = nil) {
        request = PutUserSettingsRequest(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays,
            comment_library_suggestions_enabled: comment_library_suggestions_enabled
        )
    }
}

struct UpdateCourseNickname: APIUseCase {
    typealias Model = Course

    let courseID: String
    let nickname: String

    var cacheKey: String? { nil }
    var request: PutCourseNicknameRequest { PutCourseNicknameRequest(courseID: courseID, nickname: nickname) }

    func write(response: APICourseNickname?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        let course: Course? = client.first(where: #keyPath(Course.id), equals: item.course_id.value)
        course?.name = item.nickname
        let card: DashboardCard? = client.first(where: #keyPath(DashboardCard.id), equals: item.course_id.value)
        card?.shortName = item.nickname
    }
}

struct UpdateCustomColor: APIUseCase {
    typealias Model = ContextColor

    let context: Context
    let color: String

    var cacheKey: String? { nil }
    var request: PutCustomColorRequest { PutCustomColorRequest(context: context, color: color) }

    func write(response: PutCustomColorRequest.Body?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let color = response?.hexcode else { return }
        ContextColor.save(APICustomColors(custom_colors: [ context.canvasContextID: color ]), in: client)
    }
}
