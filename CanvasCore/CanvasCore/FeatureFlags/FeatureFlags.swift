//
//  FeatureFlags.swift
//  CanvasCore
//
//  Created by Matt Sessions on 3/7/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation
import CanvasKeymaster

// You must add the name of the feature flag both here and in
// ./rn/Teacher/src/common/feature-flags.js
// This will help when we go to remove a flag we can remove it
// from here and see where the compiler tells us we are still trying to use it
public enum FeatureFlagName: String {
    case userFilesFeatureFlag = "userFilesFeatureFlag"
}

@objc(FeatureFlags)
open class FeatureFlags: NSObject {
    public static var featureFlags: [String: Any] = [:]
    public static var exemptDomains: [String] = []
    
    // The logic in this method is duplicated from ./rn/Teacher/src/common/feature-flags.js
    // Any changes here should be duplicated into that file
    public class func featureFlagEnabled(_ flagName: FeatureFlagName) -> Bool {
        // always return true if in development
        #if DEBUG
        return true
        #endif
        
        
        let baseURL = CanvasKeymaster.the().currentClient.baseURL
        if let baseURL = baseURL {
            let base = baseURL.absoluteString
            // return true if the domain is in the list of always on domains
            if exemptDomains.contains(base) {
                return true
            }
            
            if let featureFlag = featureFlags[flagName.rawValue] as? [String: Any] {
                // if the flag exists return whether or not the domain is listed in
                // the exempt institutions
                if let institutions = featureFlag["institutions"] as? [String] {
                    print("institutions", institutions, base)
                    return institutions.contains(base)
                }
            } else {
                // if the flag doesn't exist then it must not be a feature flag
                return true
            }
        }
        // if the feature flag exists or for any other reason not accounted for
        // turn off the feature flag
        return false
    }
    
    // For obj-c
    public class func featureFlagEnabled(_ flagName: String) -> Bool {
        if let flagName = FeatureFlagName(rawValue: flagName) {
            return featureFlagEnabled(flagName)
        }
        return false
    }
}
