//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

import Foundation
import SoLazy

// I wish that I could make this a string enum, but to keep compatible with obj-c it's not. 
// It has a toString() function instead
@objc public enum SecretKey: Int {
    case CanvasPSPDFKit
    case SpeedGraderPSPDFKit
    case CanvasGoogleAnalytics
    case SpeedGraderGoogleAnalytics
    case CanvasAppStore
    
    func toString() -> String {
        switch self {
        case .CanvasPSPDFKit:
            return "CanvasPSPDFKitLicenseKey"
        case .SpeedGraderPSPDFKit:
            return "SpeedGraderPSPDFKitLicenseKey"
        case .CanvasGoogleAnalytics:
            return "CanvasGoogleAnalyticsKey"
        case .SpeedGraderGoogleAnalytics:
            return "SpeedGraderGoogleAnalyticsKey"
        case .CanvasAppStore:
            return "CanvasAppStoreLinkKey"
        }
    }
}

// Toggle features based on the school/institution
@objc public enum FeatureToggleKey: Int {
    case ProtectedUserInformation
    
    func toString() -> String {
        switch self {
        case ProtectedUserInformation:
            return "ProtectedUserInformation"
        }
    }
}

public class Secrets: NSObject {

    private static let _shared = Secrets()
    
    private lazy var keys: [String: String] = {
        
        guard let path = NSBundle.secrets().URLForResource("secrets", withExtension: "plist") else {
            fatalError("keys.plist not found")
        }
        
        guard let keys = NSDictionary(contentsOfURL: path) as? [String: String] else {
            fatalError("keys.plist couldn't be created and used. :(:(:(")
        }
        
        return keys
    }()

    private func internalFetch(key: SecretKey) -> String? {
        
        let stringKey = key.toString()
        
        guard let value = keys[stringKey] else {
            fatalError("Cannot find a secret with the key \(stringKey). Please verify keys.plist")
        }
        
        return value
    }
    
    public static func fetch(key: SecretKey) -> String? {
        return Secrets._shared.internalFetch(key)
    }
    
    // Support for feature toggles that are based on a domain
    private lazy var toggles: [String: [String]]? = {
        
        guard let path = NSBundle.secrets().URLForResource("feature_toggles", withExtension: "plist") else {
            return nil
        }
        
        return NSDictionary(contentsOfURL: path) as? [String: [String]]
    }()
    
    // domain is an optional to handle cases where the user isn't logged in yet
    // While that may not be important, I did it so that this function is easier to use
    private func internalFeatureEnabled(toggle: FeatureToggleKey, domain: String?) -> Bool {
        guard let domain = domain else { return false }
        guard let toggles = toggles else { return false }
        
        guard let toggleValues = toggles[toggle.toString()] else {
            return false
        }
        
        return toggleValues.findFirst { domain.containsString($0) || $0.containsString(domain) } != nil
    }
    
    public static func featureEnabled(toggle: FeatureToggleKey, domain: String?) -> Bool {
        return Secrets._shared.internalFeatureEnabled(toggle, domain: domain)
    }
}
