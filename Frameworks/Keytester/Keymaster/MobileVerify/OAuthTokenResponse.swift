
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