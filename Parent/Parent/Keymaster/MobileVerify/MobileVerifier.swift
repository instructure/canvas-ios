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

import UIKit
import CanvasCore

public enum MobileVerifyResult: Int {
    case success = 0
    case other = 1
    case badSite = 2
    case badUserAgent = 3
    case emptyResponse = 4
    case noResult = 5
    case jsonParseError = 6

    static let mobileVerifyErrorDomain = "com.instructure.mobileverify"
    
    static func errorForResult(_ result: MobileVerifyResult) -> NSError {
        return NSError(domain: self.mobileVerifyErrorDomain, code: result.rawValue, userInfo: [ NSLocalizedDescriptionKey: errorMessageForResult(result) ])
    }
    
    static func errorMessageForResult(_ result: MobileVerifyResult) -> String {
        switch result {
        case .success:
            return ""
        case other:
            return NSLocalizedString("Not authorized.", tableName: "Localizable", bundle: .parent, value: "", comment: "Not authorized")
        case badSite:
            return NSLocalizedString("Invalid Canvas URL.", tableName: "Localizable", bundle: .parent, value: "", comment: "Invalid Canvas URL")
        case badUserAgent:
            return NSLocalizedString("Invalid User Agent.", tableName: "Localizable", bundle: .parent, value: "", comment: "Invalid User Agent")
        case emptyResponse:
            return NSLocalizedString("Empty Response.", tableName: "Localizable", bundle: .parent, value: "", comment: "Empty Response")
        case noResult:
            return NSLocalizedString("No Result.", tableName: "Localizable", bundle: .parent, value: "", comment: "No Result")
        case jsonParseError:
            return NSLocalizedString("JSON Parsing Error.", tableName: "Localizable", bundle: .parent, value: "", comment: "JSON Parsing Error")
        }
    }
}

public typealias MobileVerifySuccess = (_ response: MobileVerifyResponse) -> ()
public typealias MobileVerifyFailure = (_ error: NSError) -> ()

/*
* Responsible for checking the status of a given domain to verify they are paying customers.
*/
open class MobileVerifier {
    
    open var appName = "iCanvas"  // Let's keep one here that we know works so we can test
    public init() {}
    
    // ---------------------------------------------
    // MARK: - Public Methods
    // ---------------------------------------------
    fileprivate let baseMobileVerifyURL = "https://canvas.instructure.com/api/v1/mobile_verify.json?domain="
    open func mobileVerify(_ domain: String, success: @escaping MobileVerifySuccess, failure: @escaping MobileVerifyFailure) {
        guard let mobileVerifyURL = URL(string: "\(baseMobileVerifyURL)\(domain)") else {
            return
        }
        
        var request = URLRequest(url: mobileVerifyURL)
        request.addValue(userAgent(), forHTTPHeaderField: "User-Agent")
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            // If there was a network error, pass it on up the chain
            if let error = error {
                failure(error as NSError)
                return
            }
            
            // If we have no data lets let someone know
            guard let data = data else {
                let error = MobileVerifyResult.errorForResult(MobileVerifyResult.emptyResponse)
                failure(error)
                return
            }
            
            do {
                // Create a response object
                let responseJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let mobileVerifyObject = MobileVerifyResponse.fromJSON(responseJSON) {
                    success(mobileVerifyObject)
                }
            } catch let error as NSError {
                // Whoops.  Couldn't parse the JSON :-/
                failure(error)
                return
            }
        }
        
        task.resume()
    }

    // ---------------------------------------------
    // MARK: - Private Methods
    // ---------------------------------------------
    // Format : "[App Name]/[App Version] ([App Build Number])   [Device Model]/[Device System Version]"
    fileprivate func userAgent() -> String {
        if let info = Bundle.main.infoDictionary,
            let build = info[kCFBundleVersionKey as String] as? String,
            let version = info["CFBundleShortVersionString"] as? String  {
                let deviceModel = UIDevice.current.modelName
                let systemVersion = UIDevice.current.systemVersion
                let userAgent = "\(appName)/\(version) (\(build))   \(deviceModel)/iOS \(systemVersion)"
                return userAgent
        }
        
        return "\(appName)/1.0 (1)   \(UIDevice.current.modelName)/iOS \(UIDevice.current.systemVersion)"
    }

}
