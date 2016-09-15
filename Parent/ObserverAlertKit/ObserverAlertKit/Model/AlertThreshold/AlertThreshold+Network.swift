//
//  AlertThreshold+Network.swift
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

public extension AlertThreshold {
    static func getAllAlertThresholds(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertThresholdAPI.getAllAlertThresholds(session)
        return session.paginatedJSONSignalProducer(request)
    }

    static func getAlertThresholdsByStudent(session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertThresholdAPI.getAlertThresholdByObservee(session, parentID: session.user.id, studentID: studentID)
        return session.paginatedJSONSignalProducer(request)
    }

    static func insertAlertThreshold(session: Session, observerID: String, studentID: String, type: String, threshold: String?) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertThresholdAPI.insertAlertThreshold(session, observerID: observerID, studentID: studentID, alertType: type, threshold: threshold)
        return session.JSONSignalProducer(request)
    }

    func updateAlertThreshold(session: Session, observerID: String) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertThresholdAPI.updateAlertThreshold(session, observerID: observerID, alertThresholdID: id, alertType: type.rawValue, threshold: threshold)
        return session.JSONSignalProducer(request)
    }

    func deleteAlertThreshold(session: Session, observerID: String, thresholdID: String) throws -> SignalProducer<(), NSError> {
        let request = try AlertThresholdAPI.deleteAlertThreshold(session, observerID: observerID, alertThresholdID: thresholdID)
        return session.emptyResponseSignalProducer(request)
    }
}