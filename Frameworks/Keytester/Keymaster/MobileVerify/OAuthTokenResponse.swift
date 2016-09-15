//
//  OAuthTokenResponse.swift
//  Keymaster
//
//  Created by Brandon Pluim on 1/5/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation

import TooLegit
import SoLazy

public struct OAuthToken {
    public let accessToken: String
    public let refreshToken: String
    public let userID: Int
    public let userName: String
    
    static func fromJSON(json: AnyObject?) -> OAuthToken? {
        if let json = json as? [String: AnyObject]{
            if let
                accessToken = json["access_token"] as? String,
                refreshToken = json["refresh_token"] as? String,
                userObj = json["user"] as? [String: AnyObject],
                userID = userObj["id"] as? Int,
                userName = userObj["name"] as? String
            {
                let token = OAuthToken(accessToken: accessToken, refreshToken: refreshToken, userID: userID, userName: userName)
                return token
            }else{
                print("error parsing json to OAuthToken")
            }
        }
        return nil
    }
    
}