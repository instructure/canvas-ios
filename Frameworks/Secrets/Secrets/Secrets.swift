
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

public class Secrets: NSObject {

    private static let _shared = Secrets()
    
    private lazy var keys: [String: String] = {
        
        guard let path = NSBundle.secrets().URLForResource("secrets", withExtension: "plist") else {
            assert(false, "keys.plist not found")
        }
        
        guard let keys = NSDictionary(contentsOfURL: path) as? [String: String] else {
            assert(false, "keys.plist couldn't be created and used. :(:(:(")
        }
        
        return keys
    }()

    private func internalFetch(key: SecretKey) -> String? {
        
        let stringKey = key.toString()
        
        guard let value = keys[stringKey] else {
            assert(false, "Cannot find a secret with the key \(stringKey). Please verify keys.plist")
        }
        
        assert(value.isEmpty == false, "Missing secret value for key: \(stringKey)")
        
        return value
    }
    
    public static func fetch(key: SecretKey) -> String? {
        return Secrets._shared.internalFetch(key)
    }
}
