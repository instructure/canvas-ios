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

public struct APIFeatureFlagState: Codable {

    public enum State: String, Codable {
        /// (valid only for account context) The feature is `off` in the account, but may be enabled in sub-accounts and courses by setting a feature flag `on` the sub-account or course.
        case allowed
        /// (valid only for account context) The feature is `on` in the account, but may be disabled in sub-accounts and courses by setting a feature flag `off` the sub-account or course.
        case allowed_on
        /// The feature is turned `on` unconditionally for the user, course, or account and sub-accounts.
        case on
        /// The feature is not available for the course, user, or account and sub-accounts.
        case off
    }

    public let feature: String
    public let state: State
    public let locked: Bool

    private let context_id: String
    private let context_type: String

    init(feature: String, state: State, locked: Bool, context_id: String, context_type: String) {
        self.feature = feature
        self.state = state
        self.locked = locked
        self.context_id = context_id
        self.context_type = context_type
    }

    public var contextType: ContextType? {
        return ContextType(rawValue: context_type.lowercased())
    }

    public var canvasContextID: String {
        return "\(context_type.lowercased())_\(context_id)"
    }

    public func overriden(state: State, context: Context) -> Self {
        APIFeatureFlagState(
            feature: feature,
            state: state,
            locked: locked,
            context_id: context.id,
            context_type: context.contextType.rawValue
        )
    }
}
