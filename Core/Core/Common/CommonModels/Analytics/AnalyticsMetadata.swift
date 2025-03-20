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

public struct AnalyticsMetadata {
    public struct VisitorData: Codable {
        let id: String
        let locale: String

        public func toMap() -> [String: Any]? {
            guard let data = try? JSONEncoder().encode(self) else {
                return nil
            }
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
    }

    public struct AccountData: Codable {
        let id: String
        let surveyOptOut: Bool

        public func toMap() -> [String: Any]? {
            guard let data = try? JSONEncoder().encode(self) else {
                return nil
            }
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
    }

    public let userId: String
    public let accountUUID: String
    public let visitorData: VisitorData
    public let accountData: AccountData

    public init(userId: String, accountUUID: String, visitorData: VisitorData, accountData: AccountData) {
        self.userId = userId
        self.accountUUID = accountUUID
        self.visitorData = visitorData
        self.accountData = accountData
    }
}
