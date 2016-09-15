//
//  Airwolf.swift
//  Airwolf
//
//  Created by Ben Kraus on 5/11/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Marshal

public struct Airwolf {
    public static func authenticate(email email: String, password: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AirwolfAPI.authenticateRequest(email: email, password: password)
        return Session.unauthenticated.JSONSignalProducer(request)
    }

    public static func createAccount(email email: String, password: String, firstName: String, lastName: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AirwolfAPI.createAccountRequest(email: email, password: password, firstName: firstName, lastName: lastName)
        return Session.unauthenticated.JSONSignalProducer(request)
    }

    public static func sendPasswordResetEmail(email email: String) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.sendPasswordResetEmailRequest(email: email)
        return Session.unauthenticated.emptyResponseSignalProducer(request)
    }

    public static func resetPassword(email email: String, password: String, token: String) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.resetPasswordRequest(email: email, password: password, token: token)
        return Session.unauthenticated.emptyResponseSignalProducer(request)
    }
}
