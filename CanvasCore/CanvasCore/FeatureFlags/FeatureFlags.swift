//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CanvasKeymaster

// You must add the name of the feature flag both here and in
// ./rn/Teacher/src/common/feature-flags.js
// This will help when we go to remove a flag we can remove it
// from here and see where the compiler tells us we are still trying to use it
public enum FeatureFlagName: String {
    case favoriteGroups
    case newGroupNavigation
    case newStudentAssignmentView
    case conferences
}

@objc(FeatureFlags)
open class FeatureFlags: NSObject {
    public static var featureFlags: [String: Any] = [:]
    public static var exemptDomains: [String] = []
    
    // The logic in this method is duplicated from ./rn/Teacher/src/common/feature-flags.js
    // Any changes here should be duplicated into that file
    public class func featureFlagEnabled(_ flagName: FeatureFlagName) -> Bool {
        guard let baseURL = CanvasKeymaster.the().currentClient?.baseURL?.absoluteString else { return false }
        // return true if the domain is in the list of always on domains
        if exemptDomains.contains(baseURL) {
            return true
        }
        
        if let featureFlag = featureFlags[flagName.rawValue] as? [String: [String: Any]] {
            if let exemptions = featureFlag["exempt"] {
                // if the flag exists return whether or not the domain is listed in
                // the exemptions
                if let institutions = exemptions["domains"] as? [String] {
                    return institutions.contains(baseURL)
                }

                if let apps = exemptions["apps"] as? [String] {
                    return apps.contains(NativeLoginManager.shared().app.rawValue)
                }
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
    public class func featureFlagEnabledObjC(_ flagName: String) -> Bool {
        if let flagName = FeatureFlagName(rawValue: flagName) {
            return featureFlagEnabled(flagName)
        }
        return false
    }
}
