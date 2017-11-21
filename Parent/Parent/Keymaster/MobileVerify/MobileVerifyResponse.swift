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
import CanvasCore

public struct MobileVerifyResponse {
    public let authorized : Bool
    public let result : MobileVerifyResult
    
    public let clientID : String?
    public let clientSecret : String?
    public let baseURL : URL?
    public let apiKey : String?
}

extension MobileVerifyResponse {
    public static func fromJSON(_ json: Any?) -> MobileVerifyResponse? {
        if let json = json as? [String: AnyObject] {
            
            let kAuthorized = "authorized"
            let kBaseURL = "base_url"
            let kClientID = "client_id"
            let kClientSecret = "client_secret"
            let kResult = "result"
            let kAPIKey = "api_key"
            
            if let
                authorized = json[kAuthorized] as? Bool,
                let result = json[kResult] as? Int
            {
                let clientID = json[kClientID] as? String
                let clientSecret = json[kClientSecret] as? String
                var baseURL: URL? = nil
                if let baseURLString = json[kBaseURL] as? String {
                    baseURL = URL(string: baseURLString)
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
