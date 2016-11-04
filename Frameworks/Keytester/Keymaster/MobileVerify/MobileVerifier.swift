
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

import UIKit
import SoLazy

public enum MobileVerifyResult: Int {
    case Success = 0
    case Other = 1
    case BadSite = 2
    case BadUserAgent = 3
    case EmptyResponse = 4
    case NoResult = 5
    case JSONParseError = 6

    static let mobileVerifyErrorDomain = "com.instructure.mobileverify"
    
    static func errorForResult(result: MobileVerifyResult) -> NSError {
        return NSError(domain: self.mobileVerifyErrorDomain, code: result.rawValue, userInfo: [ NSLocalizedDescriptionKey: errorMessageForResult(result) ])
    }
    
    static func errorMessageForResult(result: MobileVerifyResult) -> String {
        switch result {
        case .Success:
            return ""
        case Other:
            return NSLocalizedString("Not authorized.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "Not authorized")
        case BadSite:
            return NSLocalizedString("Invalid Canvas URL.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "Invalid Canvas URL")
        case BadUserAgent:
            return NSLocalizedString("Invalid User Agent.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "Invalid User Agent")
        case EmptyResponse:
            return NSLocalizedString("Empty Response.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "Empty Response")
        case NoResult:
            return NSLocalizedString("No Result.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "No Result")
        case JSONParseError:
            return NSLocalizedString("JSON Parsing Error.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.Keymaster")!, value: "", comment: "JSON Parsing Error")
        }
    }
}

public typealias MobileVerifySuccess = (response: MobileVerifyResponse) -> ()
public typealias MobileVerifyFailure = (error: NSError) -> ()

/*
* Responsible for checking the status of a given domain to verify they are paying customers.
*/
public class MobileVerifier {
    
    public var appName = "iCanvas"  // Let's keep one here that we know works so we can test
    public init() {}
    
    // ---------------------------------------------
    // MARK: - Public Methods
    // ---------------------------------------------
    private let baseMobileVerifyURL = "https://canvas.instructure.com/api/v1/mobile_verify.json?domain="
    public func mobileVerify(domain: String, success: MobileVerifySuccess, failure: MobileVerifyFailure) {
        guard let mobileVerifyURL = NSURL(string: "\(baseMobileVerifyURL)\(domain)") else {
            return
        }
        
        let request = NSMutableURLRequest(URL: mobileVerifyURL)
        request.addValue(userAgent(), forHTTPHeaderField: "User-Agent")
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // If there was a network error, pass it on up the chain
            if let error = error {
                failure(error: error)
                return
            }
            
            // If we have no data lets let someone know
            guard let data = data else {
                let error = MobileVerifyResult.errorForResult(MobileVerifyResult.EmptyResponse)
                failure(error: error)
                return
            }
            
            do {
                // Create a response object
                let responseJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                if let mobileVerifyObject = MobileVerifyResponse.fromJSON(responseJSON) {
                    success(response: mobileVerifyObject)
                }
            } catch let error as NSError {
                // Whoops.  Couldn't parse the JSON :-/
                failure(error: error)
                return
            }
        }
        
        task.resume()
    }

    // ---------------------------------------------
    // MARK: - Private Methods
    // ---------------------------------------------
    // Format : "[App Name]/[App Version] ([App Build Number])   [Device Model]/[Device System Version]"
    private func userAgent() -> String {
        if let info = NSBundle.mainBundle().infoDictionary,
            build = info[kCFBundleVersionKey as String] as? String,
            version = info["CFBundleShortVersionString"] as? String  {
                let deviceModel = UIDevice.currentDevice().modelName
                let systemVersion = UIDevice.currentDevice().systemVersion
                let userAgent = "\(appName)/\(version) (\(build))   \(deviceModel)/iOS \(systemVersion)"
                return userAgent
        }
        
        return "\(appName)/1.0 (1)   \(UIDevice.currentDevice().modelName)/iOS \(UIDevice.currentDevice().systemVersion)"
    }

}