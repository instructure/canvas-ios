//
//  Secrets.swift
//  Secrets
//
//  Created by Layne Moseley on 10/28/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
