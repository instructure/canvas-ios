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
import CanvasCore

open class AlertThresholdAPI {

    open class func deleteAlertThreshold(_ session: Session, alertThresholdID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alert_thresholds/\(alertThresholdID)"

        return try session.DELETE(path)
    }

    open class func getAlertThresholds(_ session: Session, studentID: String) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alert_thresholds"
        let parameters: [String: Any] = ["student_id": studentID]

        return try session.GET(path, parameters: parameters)
    }

    open class func createAlertThreshold(_ session: Session, studentID: String, alertType: String, threshold: String? = nil) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alert_thresholds"
        let nillableParameters = [
            "user_id": studentID,
            "alert_type": alertType,
            "threshold": threshold
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.POST(path, parameters: ["observer_alert_threshold": parameters])
    }

    open class func updateAlertThreshold(_ session: Session, alertThresholdID: String, alertType: String, threshold: String? = nil) throws -> URLRequest {
        let path = "/api/v1/users/self/observer_alert_thresholds/\(alertThresholdID)"
        let nillableParameters = [
            "alert_type": alertType,
            "threshold": threshold
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.PUT(path, parameters: parameters)
    }
}
