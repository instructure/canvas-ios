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

import Foundation

/// An experimental or in-development feature
///
/// An `ExperimentalFeature` flag is useful for including code in production
/// that is not ready for all users to exercise. This is different from
/// feature flags in Canvas, which represent optional functionality in
/// production that should only apply to certain accounts, courses, or people.
public class ExperimentalFeature {
    enum State {
        case disabled, enabled
        case enabledInBeta
        case enabledForHosts([String])
    }

    private let state: State

    init(state: State) {
        self.state = state
    }

    public var isEnabled: Bool {
        if ExperimentalFeature.allEnabled { return true }
        switch state {
        case .disabled:
            return false
        case .enabled:
            return true
        case .enabledInBeta:
            guard let host = AppEnvironment.shared.currentSession?.baseURL.host else { return false }
            return host.contains(".beta.")
        case .enabledForHosts(let hosts):
            guard let host = AppEnvironment.shared.currentSession?.baseURL.host else { return false }
            return hosts.contains(host)
        }
    }

    public static var allEnabled: Bool {
        get { return UserDefaults.standard.bool(forKey: "ExperimentalFeature.allEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "ExperimentalFeature.allEnabled") }
    }
}

extension ExperimentalFeature {
    public static let assignmentListGraphQL = ExperimentalFeature(state: .disabled)
    public static let parent3 = ExperimentalFeature(state: .disabled)
    public static let conferences = ExperimentalFeature(state: .disabled)
    public static let favoriteGroups = ExperimentalFeature(state: .disabled)
    public static let simpleDiscussionRenderer = ExperimentalFeature(state: .disabled)
    public static let graphqlSpeedGrader = ExperimentalFeature(state: .disabled)
    public static let refreshTokens = ExperimentalFeature(state: .disabled)
    public static let fileDetails = ExperimentalFeature(state: .disabled)
}
