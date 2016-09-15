//
//  MobileVerifyResponse.swift
//  Keymaster
//
//  Created by Brandon Pluim on 12/1/15.
//  Copyright © 2015 Instructure. All rights reserved.
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