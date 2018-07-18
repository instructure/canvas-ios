//
// Copyright (C) 2016-present Instructure, Inc.
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

// I wish that I could make this a string enum, but to keep compatible with obj-c it's not. 
// It has a toString() function instead
@objc public enum SecretKey: Int {
    case gRPCSoSeedyAPIKey
    case canvasPSPDFKit
    case speedGraderPSPDFKit
    case canvasGoogleAnalytics
    case speedGraderGoogleAnalytics
    case canvasAppStore
    case parentAppStoreID
    case parentKeychainService
    case parentKeychainAccessGroup
    case teacherPSPDFKit
    
    func toString() -> String {
        switch self {
        case .gRPCSoSeedyAPIKey:
            return "gRPCSoSeedyAPIKey"
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
        case .parentAppStoreID:
            return "ParentAppStoreID"
        case .parentKeychainService:
            return "ParentKeychainService"
        case .parentKeychainAccessGroup:
            return "ParentKeychainAccessGroup"
        case .teacherPSPDFKit:
            return "TeacherPSPDFKitLicenseKey"
        }
    }
}

// Toggle features based on the school/institution
@objc public enum FeatureToggleKey: Int {
    case protectedUserInformation
    
    // External resources are URLs that should be redirected to safari outside of the app instead of displaying it in the app
    case externalResources
    
    func toString() -> String {
        switch self {
        case .protectedUserInformation:
            return "ProtectedUserInformation"
        case .externalResources:
            return "ExternalResources"
        }
    }
}

open class Secrets: NSObject {

    fileprivate static let _shared = Secrets()
    
    fileprivate lazy var keys: [String: String] = {
        
        guard let path = Bundle.core.url(forResource: "secrets", withExtension: "plist") else {
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

        if value.isEmpty { return nil }

        return value
    }
    
    open static func fetch(_ key: SecretKey) -> String? {
        return Secrets._shared.internalFetch(key)
    }
    
    // Support for feature toggles that are based on a domain
    fileprivate lazy var toggles: [String: [String]]? = {
        
        guard let path = Bundle.core.url(forResource: "feature_toggles", withExtension: "plist") else {
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
        
        return toggleValues.first { domain.contains($0) || $0.contains(domain) } != nil
    }
    
    open static func featureEnabled(_ toggle: FeatureToggleKey, domain: String?) -> Bool {
        return Secrets._shared.internalFeatureEnabled(toggle, domain: domain)
    }
}

extension Secrets {
    
    // Quick way to check if a url is a external resource from one central place
    @objc open static func urlIsExternalResource(_ aURL: URL?) -> Bool {
        guard let url = aURL?.absoluteString else { return false }
        guard let toggles = Secrets._shared.toggles else { return false }
        guard let externalURLs = toggles[FeatureToggleKey.externalResources.toString()] else { return false }
        return externalURLs.filter({ (value) -> Bool in
            return url.contains(value)
        }).count > 0
    }
    
    @objc open static func openExternalResourceIfNecessary(aURL: URL?) -> Bool {
        guard let url = aURL else { return false }
        guard urlIsExternalResource(url) else { return false }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return true
        } else {
            return UIApplication.shared.openURL(url)
        }
    }
}
