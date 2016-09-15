//
//  HTTPHeaders.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation

/**
Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
*/
let defaultHTTPHeaders: [String: String] = {
    // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
    let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"
    
    // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
    let acceptLanguage: String = {
        var components: [String] = []
        for (index, languageCode) in (NSLocale.preferredLanguages() as [String]).enumerate() {
            let q = 1.0 - (Double(index) * 0.1)
            components.append("\(languageCode);q=\(q)")
            if q <= 0.5 {
                break
            }
        }
        
        return components.joinWithSeparator(",")
    }()
    
    // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
    let userAgent: String = {
        if let info = NSBundle.mainBundle().infoDictionary {
            let executable: AnyObject = info[kCFBundleExecutableKey as String] ?? "Unknown"
            let bundle: AnyObject = info[kCFBundleIdentifierKey as String] ?? "Unknown"
            let version: AnyObject = info[kCFBundleVersionKey as String] ?? "Unknown"
            let os: AnyObject = NSProcessInfo.processInfo().operatingSystemVersionString ?? "Unknown"
            
            var mutableUserAgent = NSMutableString(string: "\(executable)/\(bundle) (\(version); OS \(os))") as CFMutableString
            let transform = NSString(string: "Any-Latin; Latin-ASCII; [:^ASCII:] Remove") as CFString
            
            if CFStringTransform(mutableUserAgent, UnsafeMutablePointer<CFRange>(nil), transform, false) {
                return mutableUserAgent as String
            }
        }
        
        return "ThreeLegit"
    }()
    
    return [
        "Accept-Encoding": acceptEncoding,
        "Accept-Language": acceptLanguage,
        "User-Agent": userAgent
    ]
}()
