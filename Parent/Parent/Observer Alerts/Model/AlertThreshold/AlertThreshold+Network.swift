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
import CanvasCore

public extension AlertThreshold {
    static func getAlertThresholds(_ session: Session, studentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try AlertThresholdAPI.getAlertThresholds(session, studentID: studentID)
        return session.paginatedJSONSignalProducer(request)
    }

    static func createAlertThreshold(_ session: Session, studentID: String, type: String, threshold: String?) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertThresholdAPI.createAlertThreshold(session, studentID: studentID, alertType: type, threshold: threshold)
        return session.JSONSignalProducer(request)
    }

    func updateAlertThreshold(_ session: Session) throws -> SignalProducer<JSONObject, NSError> {
        let request = try AlertThresholdAPI.updateAlertThreshold(session, alertThresholdID: id, alertType: type.rawValue, threshold: threshold)
        return session.JSONSignalProducer(request)
    }

    func deleteAlertThreshold(_ session: Session, thresholdID: String) throws -> SignalProducer<(), NSError> {
        let request = try AlertThresholdAPI.deleteAlertThreshold(session, alertThresholdID: thresholdID)
        return session.emptyResponseSignalProducer(request)
    }
}
