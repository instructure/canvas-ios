//
//  User+Network.swift
//  Peeps
//
//  Created by Brandon Pluim on 3/8/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import ReactiveCocoa
import TooLegit
import Marshal

extension User {
    public static func getObserveeUsers(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try UserAPI.getObserveeUsers(session)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func getObserveeUser(session: Session, observeeID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try UserAPI.getObserveeUser(session, observeeID: observeeID)
        return session.JSONSignalProducer(request)
    }

    public static func removeObserver(session: Session, observeeID: String) throws -> SignalProducer<(), NSError> {
        let request = try UserAPI.removeObserver(session, observeeID: observeeID)
        return session.emptyResponseSignalProducer(request)
    }

    public static func addObserver(session: Session, accessToken: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try UserAPI.addObserver(session, accessToken: accessToken)
        return session.paginatedJSONSignalProducer(request)
    }

    public static func removeAccessToken(session: Session) throws -> SignalProducer<(), NSError> {
        let request = try UserAPI.removeAccessToken(session)
        return session.emptyResponseSignalProducer(request)
    }
}
