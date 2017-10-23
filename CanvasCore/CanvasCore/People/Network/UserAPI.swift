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
    
    




open class UserAPI {
    open static func getUsers(_ session: Session, context: ContextID) throws -> URLRequest {
        let path = context.apiPath/"users"
        let parameters = ["include": ["enrollments", "avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    open class func getObserveeUsers(_ session: Session) throws -> URLRequest {
        let path = "/api/v1/users/self/observees"
        let parameters = ["include": ["avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    open class func getObserveeUser(_ session: Session, observeeID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observees/\(observeeID)"
        let parameters = ["include": ["avatar_url"]]
        return try session.GET(path, parameters: parameters)
    }

    open class func removeObserver(_ session: Session, observeeID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observees/\(observeeID)"
        return try session.DELETE(path)
    }

    open class func addObserver(_ session: Session, accessToken: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observees"
        let parameters = ["access_token": accessToken]
        return try session.POST(path, parameters: parameters)
    }

    open class func removeAccessToken(_ session: Session) throws -> URLRequest {
        return try session.DELETE("/api/v1/login/oauth2/token")
    }
}
