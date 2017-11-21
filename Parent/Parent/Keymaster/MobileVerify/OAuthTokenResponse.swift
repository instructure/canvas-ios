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

public struct OAuthToken {
    public let accessToken: String
    public let refreshToken: String
    public let userID: Int
    public let userName: String
    
    static func fromJSON(_ json: Any?) -> OAuthToken? {
        if let json = json as? [String: AnyObject]{
            if let
                accessToken = json["access_token"] as? String,
                let refreshToken = json["refresh_token"] as? String,
                let userObj = json["user"] as? [String: AnyObject],
                let userID = userObj["id"] as? Int,
                let userName = userObj["name"] as? String
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
