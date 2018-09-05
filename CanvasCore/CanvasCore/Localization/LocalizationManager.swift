//
//  LocalizationManager.swift
//  CanvasCore
//
//  Created by Layne Moseley on 5/21/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

import Foundation

let InstUserLocale = "InstUserLocale"
public class LocalizationManager: NSObject {
    
    public static var currentLocale: String {
        guard let locale = UserDefaults.standard.string(forKey: InstUserLocale) else {
            return Locale.current.identifier
        }
        
        return locale
    }
    
    // If there is a custom localization set and that main bundle exists, return that bundle
    // Otherwise, return the main bundle
    // This is useful for app localizations, but not localizations for frameworks
    public static var localizedMainBundle: Bundle {
        if let path = Bundle.main.path(forResource: self.currentLocale, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle
        }
        
        return Bundle.main
    }
    
    
    public static func localizedBundleForClass(aClass: AnyClass) -> Bundle {
        let bundle = Bundle(for: aClass)
        if let path = bundle.path(forResource: self.currentLocale, ofType: "lproj"),
            let localizedBundle = Bundle(path: path) {
            return localizedBundle
        }
        
        return bundle
    }
    
    @objc
    public static func setCurrentLocale(_ locale: NSString) {
        UserDefaults.standard.set(locale, forKey: InstUserLocale)
        UserDefaults.standard.set([locale], forKey: "AppleLanguages")
    }
}
