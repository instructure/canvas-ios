//
//  Alert+Network.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import TooLegit
import ReactiveCocoa
import Marshal
import Airwolf

extension Alert {
    static func getObserveeAlerts(session: Session, observeeID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertAPI.getAlertsForParent(session, observerID: session.user.id, studentID: observeeID)
        return session.paginatedJSONSignalProducer(request)
    }

    static func getAlerts(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertAPI.getAlerts(session)
        return session.paginatedJSONSignalProducer(request)
    }

    func markAsRead(read: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.updateAlert(session, observerID: session.user.id, alertID: id, read: read)
        return session.JSONSignalProducer(request)
    }

    func markDismissed(dismissed: Bool, session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertAPI.updateAlert(session, observerID: session.user.id, alertID: id, dismissed: dismissed)
        return session.JSONSignalProducer(request)
    }
}