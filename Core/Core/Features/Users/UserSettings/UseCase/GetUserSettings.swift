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

    private let userID: String
    private let shouldSaveAnalyticsApiKey: Bool

    public init(userID: String = "self", shouldSaveAnalyticsApiKey: Bool = false) {
        self.userID = userID
        self.shouldSaveAnalyticsApiKey = shouldSaveAnalyticsApiKey
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

    public func write(response: APIUserSettings?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }

        UserSettings.save(response, in: client)

        if shouldSaveAnalyticsApiKey, let pendoApiKey = response.pendoApiKey?.nilIfEmpty {
            Analytics.shared.handler?.storePendoApiKey(pendoApiKey)
        }
    }
}

private extension APIUserSettings {
    var pendoApiKey: String? {
        guard let app = AppEnvironment.shared.app else { return nil }

        return switch app {
        case .student, .horizon, .nextgen: pendo_mobile_student_api_key
        case .teacher: pendo_mobile_teacher_api_key
        case .parent: pendo_mobile_parent_api_key
        }
    }
}
