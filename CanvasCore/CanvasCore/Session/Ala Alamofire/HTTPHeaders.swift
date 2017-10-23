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


//  This code is extracted and slightly modified from Alamofire

//  Copyright (c) 2014-2016 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


/// Creates default values for the "Accept-Encoding", "Accept-Language" and "User-Agent" headers.
public let defaultHTTPHeaders: [String: String] = {
    // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
    let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
    
    // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
    let localizations = Bundle.main.preferredLocalizations
    let acceptLanguage = localizations.prefix(6).enumerated().map { index, languageCode in
        let quality = 1.0 - (Double(index) * 0.1)
        return "\(languageCode);q=\(quality)"
    }.joined(separator: ", ")
    
    // User-Agent Header; see https://tools.ietf.org/html/rfc7231#section-5.5.3
    // Example: `iOS Example/1.0 (org.alamofire.iOS-Example; build:1; iOS 10.0.0) Alamofire/4.0.0`
    let userAgent: String = {
        if let info = Bundle.main.infoDictionary {
            let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
            let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            
            let osNameVersion: String = {
                let version = ProcessInfo.processInfo.operatingSystemVersion
                let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                
                let osName: String = {
                    #if os(iOS)
                        return "iOS"
                    #elseif os(watchOS)
                        return "watchOS"
                    #elseif os(tvOS)
                        return "tvOS"
                    #elseif os(macOS)
                        return "OS X"
                    #elseif os(Linux)
                        return "Linux"
                    #else
                        return "Unknown"
                    #endif
                }()
                
                return "\(osName) \(versionString)"
            }()
            
            let alamofireVersion: String = {
                guard
                    let afInfo = Bundle.core.infoDictionary,
                    let build = afInfo["CFBundleShortVersionString"]
                    else { return "Unknown" }
                
                return "TooLegit/\(build)"
            }()
            
            return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion)) \(alamofireVersion)"
        }
        
        return "TooLegit"
    }()
    
    return [
        "Accept-Encoding": acceptEncoding,
        "Accept-Language": acceptLanguage,
        "User-Agent": userAgent
    ]
}()

extension URLRequest {
    
    /// Adds our default set of headers to the url request
    /// *Note* Will OVERWRITE any other headers that were set
    public mutating func addDefaultHTTPHeaders() {
        defaultHTTPHeaders.forEach { (key, value) in
            self.addValue(value, forHTTPHeaderField: key)
        }
    }
}
