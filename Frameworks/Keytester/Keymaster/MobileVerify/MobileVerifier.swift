//
//  MobileVerifier.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/1/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
            return NSLocalizedString("", value: "Not authorized.", comment: "")
        case BadSite:
            return NSLocalizedString("", value: "Invalid Canvas URL.", comment: "")
        case BadUserAgent:
            return NSLocalizedString("", value: "Invalid User Agent.", comment: "")
        case EmptyResponse:
            return NSLocalizedString("", value: "Empty Response.", comment: "")
        case NoResult:
            return NSLocalizedString("", value: "No Result.", comment: "")
        case JSONParseError:
            return NSLocalizedString("", value: "JSON Parsing Error.", comment: "")
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