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

/**
Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
*/
let defaultHTTPHeaders: [String: String] = {
    // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
    let acceptEncoding: String = "gzip;q=1.0,compress;q=0.5"
    
    // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
    let acceptLanguage: String = {
        
        // Airwolf doesn't support regions yet, so, this adds additional headers that strip that out
        // Example: ["de-US;q=1.0", "de;q=0.95", "ar-US;q=0.9", "ar;q=0.85", "en;q=0.80"]
        let preferred = NSLocale.preferredLanguages()
        let languages = preferred.reduce([String]()) { memo, item in
            
            if let range = item.rangeOfString("-", options: [.BackwardsSearch], range: nil, locale: nil) {
                let stripped = item.substringToIndex(range.startIndex)
                return memo + [item, stripped]
            }
            else {
                return memo + [item]
            }
            }.enumerate().map { index, element in
                return "\(element);q=\(1.0 - (Double(index) * 0.05))"
        }
        
        return languages.joinWithSeparator(",")
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

extension NSMutableURLRequest {
    
    /// Adds our default set of headers to the url request
    /// *Note* Will OVERWRITE any other headers that were set
    public func addDefaultHTTPHeaders() {
        defaultHTTPHeaders.forEach { (key, value) in
            self.addValue(value, forHTTPHeaderField: key)
        }
    }
}
