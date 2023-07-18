//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core

// https://canvas.instructure.com/doc/api/feature_flags.html#method.feature_flags.update
public struct SetDSFeatureFlagRequest: APIRequestable {
    public typealias Response = DSFeatureFlag

    public let method = APIMethod.put
    public let path: String
    public let body: Body?

    public init(body: Body, courseId: String, feature: DSFeature) {
        self.body = body
        self.path = "courses/\(courseId)/features/flags/\(feature.feature)"
    }
}

extension SetDSFeatureFlagRequest {
    public struct Body: Encodable {
        let state: String

        public init(state: DSFeatureFlagState) {
            self.state = state.rawValue
        }
    }
}

public struct GetDSFeaturesRequest: APIRequestable {
    public typealias Response = [DSFeature]

    public let method = APIMethod.get
    public let path: String

    public init(courseId: String, accountID: String? = nil) {
        self.path = accountID != nil ? "accounts/\(accountID!)/features" : "courses/\(courseId)/features"
    }
}

public enum DSFeatureFlagState: String {
    case off
    case allowed
    case on
}
