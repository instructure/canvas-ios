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