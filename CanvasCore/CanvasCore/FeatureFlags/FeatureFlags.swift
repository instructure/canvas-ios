//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import Core

// You must add the name of the feature flag both here and in
// ./rn/Teacher/src/common/feature-flags.js
// This will help when we go to remove a flag we can remove it
// from here and see where the compiler tells us we are still trying to use it
public enum FeatureFlagName: String {
    case favoriteGroups
    case conferences
}

@objc(FeatureFlags)
open class FeatureFlags: NSObject {
    @objc public static var featureFlags: [String: Any] = [
        "favoriteGroups": [:],
        "simpleDiscussionRenderer": [:],
        "conferences": [:],
    ]
    
    // The logic in this method is duplicated from ./rn/Teacher/src/common/feature-flags.js
    // Any changes here should be duplicated into that file
    public class func featureFlagEnabled(_ flagName: FeatureFlagName) -> Bool {
        if let featureFlag = featureFlags[flagName.rawValue] as? [String: Any] {
            if let exemptions = featureFlag["exempt"] as? [String: Any] {
                // if the flag exists return whether or not the domain is listed in
                // the exemptions
                if let institutions = exemptions["domains"] as? [String],
                    let baseURL = AppEnvironment.shared.currentSession?.baseURL.absoluteString,
                    institutions.contains(baseURL) {
                    return true
                }
            }
            if let enabled = featureFlag["enabled"] as? Bool, enabled {
                return true
            }
        } else {
            // if the flag doesn't exist then it must not be a feature flag
            return true
        }
        // if the feature flag exists or for any other reason not accounted for
        // turn off the feature flag
        return false
    }
    
    // For obj-c
    @objc public class func featureFlagEnabledObjC(_ flagName: String) -> Bool {
        if let flagName = FeatureFlagName(rawValue: flagName) {
            return featureFlagEnabled(flagName)
        }
        return false
    }
}
