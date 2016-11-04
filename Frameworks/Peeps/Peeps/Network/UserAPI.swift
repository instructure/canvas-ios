
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
    
    

import TooLegit
import SoLazy

public class UserAPI {
    public static func getUsers(session: Session, context: ContextID) throws -> NSURLRequest {
        let path = context.apiPath/"users"
        let parameters = ["include": ["enrollments", "avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    public class func getObserveeUsers(session: Session) throws -> NSURLRequest {
        let path = "/api/v1/users/self/observees"
        let parameters = ["include": ["avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    public class func getObserveeUser(session: Session, observeeID: String) throws -> NSURLRequest {
        let path = "/api/v1/users/self/observees/\(observeeID)"
        let parameters = ["include": ["avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    public class func removeObserver(session: Session, observeeID: String) throws -> NSURLRequest {
        let path = "/api/v1/users/self/observees/\(observeeID)"
        return try session.DELETE(path)
    }

    public class func addObserver(session: Session, accessToken: String) throws -> NSURLRequest {
        let path = "/api/v1/users/self/observees"
        let parameters = ["access_token": accessToken]
        return try session.POST(path, parameters: parameters)
    }

    public class func removeAccessToken(session: Session) throws -> NSURLRequest {
        return try session.DELETE("/api/v1/login/oauth2/token")
    }
}
