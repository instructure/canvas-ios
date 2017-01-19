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
    case canvasPSPDFKit
    case speedGraderPSPDFKit
    case canvasGoogleAnalytics
    case speedGraderGoogleAnalytics
    case canvasAppStore
    
    func toString() -> String {
        switch self {
        case .canvasPSPDFKit:
            return "CanvasPSPDFKitLicenseKey"
        case .speedGraderPSPDFKit:
            return "SpeedGraderPSPDFKitLicenseKey"
        case .canvasGoogleAnalytics:
            return "CanvasGoogleAnalyticsKey"
        case .speedGraderGoogleAnalytics:
            return "SpeedGraderGoogleAnalyticsKey"
        case .canvasAppStore:
            return "CanvasAppStoreLinkKey"
        }
    }
}

// Toggle features based on the school/institution
@objc public enum FeatureToggleKey: Int {
    case protectedUserInformation
    
    func toString() -> String {
        switch self {
        case .protectedUserInformation:
            return "ProtectedUserInformation"
        }
    }
}

open class Secrets: NSObject {

    fileprivate static let _shared = Secrets()
    
    fileprivate lazy var keys: [String: String] = {
        
        guard let path = Bundle.secrets.url(forResource: "secrets", withExtension: "plist") else {
            fatalError("keys.plist not found")
        }
        
        guard let keys = NSDictionary(contentsOf: path) as? [String: String] else {
            fatalError("keys.plist couldn't be created and used. :(:(:(")
        }
        
        return keys
    }()

    fileprivate func internalFetch(_ key: SecretKey) -> String? {
        
        let stringKey = key.toString()
        
        guard let value = keys[stringKey] else {
            fatalError("Cannot find a secret with the key \(stringKey). Please verify keys.plist")
        }
        
        return value
    }
    
    open static func fetch(_ key: SecretKey) -> String? {
        return Secrets._shared.internalFetch(key)
    }
    
    // Support for feature toggles that are based on a domain
    fileprivate lazy var toggles: [String: [String]]? = {
        
        guard let path = Bundle.secrets.url(forResource: "feature_toggles", withExtension: "plist") else {
            return nil
        }
        
        return NSDictionary(contentsOf: path) as? [String: [String]]
    }()
    
    // domain is an optional to handle cases where the user isn't logged in yet
    // While that may not be important, I did it so that this function is easier to use
    fileprivate func internalFeatureEnabled(_ toggle: FeatureToggleKey, domain: String?) -> Bool {
        guard let domain = domain else { return false }
        guard let toggles = toggles else { return false }
        
        guard let toggleValues = toggles[toggle.toString()] else {
            return false
        }
        
        return toggleValues.findFirst { domain.contains($0) || $0.contains(domain) } != nil
    }
    
    open static func featureEnabled(_ toggle: FeatureToggleKey, domain: String?) -> Bool {
        return Secrets._shared.internalFeatureEnabled(toggle, domain: domain)
    }
}
