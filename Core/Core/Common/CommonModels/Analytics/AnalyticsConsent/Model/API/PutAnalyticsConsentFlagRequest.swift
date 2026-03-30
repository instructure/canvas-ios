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

struct PutAnalyticsConsentFlagRequest: APIRequestable {
    struct Response: Codable {
        let data: String
    }

    struct Body: Codable {
        let ns: String
        let data: String
    }

    let value: Bool

    var method: APIMethod { .put }
    var path: String { "users/self/custom_data/data_sync" }
    var body: Body? {
        Body(ns: "MOBILE_CANVAS_COOKIE_CONSENT", data: String(value))
    }
}
