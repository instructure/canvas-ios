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
