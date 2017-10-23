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
import ReactiveSwift
import Marshal
import AVFoundation
import WebKit
import CanvasCore

public struct Airwolf {
    public static func authenticate(email: String, password: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AirwolfAPI.authenticateRequest(email: email, password: password)
        print("authenticating: \(request.url?.absoluteString ?? "wut!?")")
        return Session.unauthenticated.JSONSignalProducer(request)
    }

    public static func createAccount(email: String, password: String, firstName: String, lastName: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AirwolfAPI.createAccountRequest(email: email, password: password, firstName: firstName, lastName: lastName)
        return Session.unauthenticated.JSONSignalProducer(request)
    }

    public static func sendPasswordResetEmail(email: String) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.sendPasswordResetEmailRequest(email: email)
        return Session.unauthenticated.emptyResponseSignalProducer(request)
    }

    public static func resetPassword(email: String, password: String, token: String) throws -> SignalProducer<(), NSError> {
        let request = try AirwolfAPI.resetPasswordRequest(email: email, password: password, token: token)
        return Session.unauthenticated.emptyResponseSignalProducer(request)
    }
}
