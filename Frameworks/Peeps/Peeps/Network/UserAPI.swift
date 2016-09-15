//
//  UserAPI.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import TooLegit
import SoLazy

public class UserAPI {
    public enum RequestType: String {
        case Event = "event"
        case Assignment = "assignment"
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
