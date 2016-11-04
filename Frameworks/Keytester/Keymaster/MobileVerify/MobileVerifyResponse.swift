
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
import SoLazy

public struct MobileVerifyResponse {
    public let authorized : Bool
    public let result : MobileVerifyResult
    
    public let clientID : String?
    public let clientSecret : String?
    public let baseURL : NSURL?
    public let apiKey : String?
}

extension MobileVerifyResponse {
    public static func fromJSON(json: AnyObject?) -> MobileVerifyResponse? {
        if let json = json as? [String: AnyObject] {
            
            let kAuthorized = "authorized"
            let kBaseURL = "base_url"
            let kClientID = "client_id"
            let kClientSecret = "client_secret"
            let kResult = "result"
            let kAPIKey = "api_key"
            
            if let
                authorized = json[kAuthorized] as? Bool,
                result = json[kResult] as? Int
            {
                let clientID = json[kClientID] as? String
                let clientSecret = json[kClientSecret] as? String
                var baseURL: NSURL? = nil
                if let baseURLString = json[kBaseURL] as? String {
                    baseURL = NSURL(string: baseURLString)
                }
                
                let apiKey = json[kAPIKey] as? String
                
                ///write code to change the URL for syllabus here.
                let response = MobileVerifyResponse(authorized: authorized, result: MobileVerifyResult(rawValue: result)!, clientID: clientID, clientSecret: clientSecret, baseURL: baseURL, apiKey: apiKey)
                return response
            }
        }
        return nil
    }
    
}