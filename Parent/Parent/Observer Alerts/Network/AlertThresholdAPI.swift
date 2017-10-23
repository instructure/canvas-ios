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

    open class func deleteAlertThreshold(_ session: Session, observerID: String, alertThresholdID: String) throws -> URLRequest {
        let path = "/alertthreshold/\(observerID)/\(alertThresholdID)"
        let parameters: [String: Any] = [:]

        return try session.DELETE(path, parameters: parameters)
    }

    open class func getAlertThresholdByObservee(_ session: Session, parentID: String, studentID: String) throws -> URLRequest {
        let path = "/alertthreshold/student/\(parentID)/\(studentID)"
        let parameters: [String: Any] = [:]

        return try session.GET(path, parameters: parameters)
    }

    open class func getAllAlertThresholds(_ session: Session) throws -> URLRequest {
        let path = "/alertthreshold/\(session.user.id)"
        let parameters: [String: Any] = [:]

        return try session.GET(path, parameters: parameters)
    }

    open class func insertAlertThreshold(_ session: Session, observerID: String, studentID: String, alertType: String, threshold: String? = nil) throws -> URLRequest {
        let path = "/alertthreshold/\(observerID)/"
        let nillableParameters: [String: Any?] = [
            "observer_id": observerID as Optional<Any>,
            "student_id": studentID as Optional<Any>,
            "alert_type": alertType as Optional<Any>,
            "threshold": threshold as Optional<Any>
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.PUT(path, parameters: parameters)
    }

    open class func updateAlertThreshold(_ session: Session, observerID: String, alertThresholdID: String, alertType: String, threshold: String? = nil) throws -> URLRequest {
        let path = "/alertthreshold/\(observerID)/\(alertThresholdID)"
        let nillableParameters: [String: Any?] = [
            "alert_type": alertType as Optional<Any>,
            "threshold": threshold as Optional<Any>
        ]

        let parameters = Session.rejectNilParameters(nillableParameters)

        return try session.POST(path, parameters: parameters)
    }
}
