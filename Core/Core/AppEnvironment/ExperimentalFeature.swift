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
    let remoteConfigKey: String
    let settingsKey: String
    var enabled: Bool

    init(remoteConfigKey: String) {
        self.remoteConfigKey = remoteConfigKey
        self.settingsKey = ExperimentalFeature.settingsKey(forConfigKey: self.remoteConfigKey)
        self.enabled = UserDefaults.standard.bool(forKey: self.settingsKey)
    }

    public var isEnabled: Bool {
        get { return enabled }
        set {
            enabled = newValue
            UserDefaults.standard.set(newValue, forKey: self.settingsKey)
        }
    }

    public static func settingsKey(forConfigKey key: String) -> String {
        return "ExperimentalFeature.\(key)"
    }
}

extension ExperimentalFeature {
    public static var allEnabled: Bool {
        get { allFeatures.filter({ $0.isEnabled == false }).count == 0 }
        set {
            for feature in allFeatures {
                feature.isEnabled = newValue
            }
        }
    }

    public static let allFeatures: [ExperimentalFeature] = [
        .parent3, .conferences, .favoriteGroups, .simpleDiscussionRenderer, .graphqlSpeedGrader, .refreshTokens, .newPageDetails,
        .fileDetails, .testing,
    ]

    // Be sure to add your feature to the `allFeatures` array as well or it will not get picked up
    // in ExperimentalFeaturesViewController.swift
    public static let parent3 = ExperimentalFeature(remoteConfigKey: "parent3")
    public static let conferences = ExperimentalFeature(remoteConfigKey: "conferences")
    public static let favoriteGroups = ExperimentalFeature(remoteConfigKey: "favorite_groups")
    public static let simpleDiscussionRenderer = ExperimentalFeature(remoteConfigKey: "simple_discussion_renderer")
    public static let graphqlSpeedGrader = ExperimentalFeature(remoteConfigKey: "graphql_speed_grader")
    public static let refreshTokens = ExperimentalFeature(remoteConfigKey: "refresh_tokens")
    public static let newPageDetails = ExperimentalFeature(remoteConfigKey: "new_page_details")
    public static let fileDetails = ExperimentalFeature(remoteConfigKey: "file_details")
    public static let assignmentListGraphQL = ExperimentalFeature(remoteConfigKey: "assignment_list_graphql")
    public static let testing = ExperimentalFeature(remoteConfigKey: "testing")
}
